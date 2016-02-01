defmodule KidsCheckin.CheckinChannel do
  use Phoenix.Channel

  def join("checkins:count", _message, socket) do
    {:ok, socket}
  end
end
