defmodule RaspdemoServerWeb.DashboardLive do
  use RaspdemoServerWeb, :live_view

  def mount(_params, _session, socket) do
    if connected?(socket) do
      RaspdemoServerWeb.Endpoint.subscribe("iot:lobby")
    end

    {:ok,
     assign(socket,
       temp: 25,
       light_percent: 55,
       light_label: "Meia luz",
       last_button_at: nil,
       button_pressed: false,
       button_count: 0,
       last_button_press: nil,
       buzzer_active: false
     )}
  end

  def render(assigns) do
    ~H"""
    <div class="bg-base-200 min-h-screen relative">
      <h1 class="text-4xl font-bold mb-8 text-center pt-8">Elixir IoT Example</h1>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-6 max-w-4xl mx-auto">
        <!-- Temperature Card -->
        <div class="card bg-base-100 shadow-xl">
          <figure class="px-10 pt-10">
            <.icon name="hero-fire" class="w-20 h-20 text-orange-500" />
          </figure>
          <div class="card-body items-center text-center">
            <h2 class="card-title">Temperature</h2>
            <div class="stat-value text-primary">{@temp}°C</div>
            <p>Current ambient temperature</p>
          </div>
        </div>
        
    <!-- Light/Dark Card -->
        <div class="card bg-base-100 shadow-xl">
          <div class="card-body items-center text-center">
            <h2 class="card-title mb-4">Luminosity</h2>

            <div class="relative flex items-center justify-center">
              <div
                class={[
                  "radial-progress bg-base-content/10",
                  if(@light_percent > 50, do: "text-warning", else: "text-info")
                ]}
                style={"--value:#{@light_percent}; --size:12rem; --thickness: 1rem;"}
                role="progressbar"
              >
                <div class="flex flex-col items-center justify-center text-base-content">
                  <%= if @light_percent > 57 do %>
                    <.icon name="hero-sun" class="w-12 h-12 text-yellow-500 mb-1" />
                    <span class="font-bold text-lg">Day</span>
                  <% else %>
                    <.icon name="hero-moon" class="w-12 h-12 text-blue-500 mb-1" />
                    <span class="font-bold text-lg">Night</span>
                  <% end %>
                  <span class="text-2xl font-mono">{@light_percent}%</span>
                </div>
              </div>
              
    <!-- Labels around -->
              <div class="absolute -bottom-2 left-0 text-xs font-bold text-base-content/50">
                Bright
              </div>
              <div class="absolute -bottom-2 right-0 text-xs font-bold text-base-content/50">
                Dark
              </div>
            </div>

            <p class="mt-4 text-sm opacity-70">{@light_label}</p>
          </div>
        </div>
        
    <!-- Buzzer Control -->
        <div class="card bg-base-100 shadow-xl">
          <figure class="px-10 pt-10">
            <.icon
              name="hero-bell-alert"
              class={[
                "w-20 h-20 transition-all duration-100",
                @buzzer_active && "text-red-600 scale-125",
                !@buzzer_active && "text-gray-400"
              ]}
            />
          </figure>
          <div class="card-body items-center text-center">
            <h2 class="card-title">Alarm</h2>
            <p>Click to emit a sound in the IoT device</p>
            <div class="card-actions mt-4">
              <button
                type="button"
                phx-click="send_beep"
                class="btn btn-lg btn-primary active:scale-95"
              >
                Emit Sound
              </button>
            </div>
          </div>
        </div>
        
    <!-- Physical Button Monitor -->
        <div class="card bg-base-100 shadow-xl">
          <figure class="px-10 pt-10">
            <div class={[
              "w-24 h-24 rounded-full flex items-center justify-center transition-all duration-200 border-4",
              @button_pressed &&
                "bg-green-500 border-green-600 shadow-[0_0_30px_rgba(34,197,94,0.6)] scale-110",
              !@button_pressed && "bg-base-300 border-base-content/10"
            ]}>
              <.icon
                name="hero-cursor-arrow-rays"
                class={[
                  "w-12 h-12 transition-colors",
                  @button_pressed && "text-white",
                  !@button_pressed && "text-base-content/30"
                ]}
              />
            </div>
          </figure>
          <div class="card-body items-center text-center">
            <h2 class="card-title">Physical Button</h2>
            <div class="stats shadow my-2 w-full">
              <div class="stat place-items-center p-2">
                <div class="stat-title text-xs">Total Clicks</div>
                <div class="stat-value text-2xl text-secondary">{@button_count}</div>
              </div>
            </div>
            <p class="text-sm text-base-content/70 min-h-[1.25rem]">
              <%= if @last_button_press do %>
                Last: {@last_button_press}
              <% else %>
                Waiting for interaction...
              <% end %>
            </p>
          </div>
        </div>
      </div>

      <footer class="footer footer-center p-4 bg-base-300 text-base-content mt-10 h-19">
        <aside>
          <p>
            Copyright © {Date.utc_today().year} - Developed by
            <a href="https://github.com/tuliocll" target="_blank" class="link link-hover font-bold">
              Tulio Calil
            </a>
          </p>
        </aside>
      </footer>
    </div>
    """
  end

  @impl true
  def handle_event("send_beep", _params, socket) do
    Process.send_after(self(), :release_alarm, 500)

    RaspdemoServerWeb.Endpoint.broadcast(
      "iot:lobby",
      "buzzer_cmd",
      %{"pattern" => "mario"}
    )

    {:noreply,
     socket
     |> assign(:buzzer_active, true)}
  end

  @impl true
  def handle_info(%{event: "sensor_update", payload: payload}, socket) do
    {:noreply,
     assign(socket,
       temp: payload.temp,
       light_percent: payload.light.percent,
       light_label: payload.light.label
     )}
  end

  def handle_info(%{event: "button_pressed", payload: _payload}, socket) do
    Process.send_after(self(), :release_button, 200)

    current_time = Calendar.strftime(DateTime.now!("Etc/UTC"), "%H:%M:%S")

    {:noreply,
     assign(socket,
       button_pressed: true,
       button_count: socket.assigns.button_count + 1,
       last_button_press: current_time
     )}
  end

  def handle_info(:release_button, socket) do
    {:noreply, assign(socket, button_pressed: false)}
  end

  def handle_info(:release_alarm, socket) do
    {:noreply, assign(socket, buzzer_active: false)}
  end

  # It´s also a gambiarra, only to prevent the LiveView from crashing/restarting
  def handle_info(%Phoenix.Socket.Broadcast{event: "buzzer_cmd"}, socket) do
    {:noreply, socket}
  end
end
