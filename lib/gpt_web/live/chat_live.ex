
defmodule GptWeb.ChatLive do
  use GptWeb, :live_view

  def mount(_params, _session, socket) do
    if connected?(socket), do: Phoenix.PubSub.subscribe(Gpt.PubSub, "chat_room")
    pid = self() |> :erlang.pid_to_list() |> List.to_string()
    {:ok, assign(socket, messages: [], username: pid)}
  end

  def handle_event("send_message", %{"message" => message}, socket) do
    msg = %{username: socket.assigns.username, body: message, timestamp: DateTime.utc_now()}
    Phoenix.PubSub.broadcast(Gpt.PubSub, "chat_room", {:new_message, msg})
    {:noreply, socket}
  end

  def handle_info({:new_message, msg}, socket) do
    {:noreply, assign(socket, messages: [msg | socket.assigns.messages])}
  end

  def render(assigns) do
    ~H"""
    <div class="p-6 max-w-lg mx-auto space-y-4">
      <h1 class="text-2xl font-bold">Live Chat</h1>
      <div class="h-64 overflow-y-auto border p-2 bg-gray-100">
        <%= for msg <- @messages do %>
          <p><strong><%= msg.username %>:</strong> <%= msg.body %></p>
        <% end %>
      </div>
      <form phx-submit="send_message">
        <input type="text" name="message" placeholder="Digite uma mensagem..." class="border p-2 w-full" required />
        <button type="submit" class="bg-blue-500 text-white px-4 py-2 mt-2">Enviar</button>
      </form>
    </div>
    """
  end
end
