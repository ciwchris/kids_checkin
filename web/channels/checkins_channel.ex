defmodule KidsCheckin.CheckinChannel do
  use Phoenix.Channel
  import Poison, only: [encode: 1]

  def join("checkins:count", _message, socket) do
    {:ok, socket}
  end

  def handle_in("inc", %{"body" => body}, socket) do

    adjustment = LruCache.get(:my_cache, "adjustment") || setCache 
    LruCache.update(:my_cache, "adjustment", Map.put(adjustment, :os.system_time(:milli_seconds), body), touch = false)

    kids = LruCache.get(:my_cache, "kids") || %{}
    {status, classes} = encode KidsCheckin.CheckinParse.formatKids(kids)

    KidsCheckin.Endpoint.broadcast("checkins:count", "count_update", %{classes: classes})
    {:noreply, socket}
  end

  def handle_in("dec", %{"body" => body}, socket) do
    adjustment = LruCache.get(:my_cache, "adjustment") || setCache
    newAdjustment = Enum.filter(adjustment, fn {key, val} -> val == body end)
    |> Enum.drop(1)
    |> Map.new()
    |> Map.merge(Enum.filter(adjustment, fn {key, val} -> val != body end) |> Map.new())

    LruCache.update(:my_cache, "adjustment", newAdjustment, touch = false)

    kids = LruCache.get(:my_cache, "kids") || %{}
    {status, classes} = encode KidsCheckin.CheckinParse.formatKids(kids)

    KidsCheckin.Endpoint.broadcast("checkins:count", "count_update", %{classes: classes})
    {:noreply, socket}
  end

  defp setCache() do
    kids = %{}
    LruCache.put(:my_cache, "adjustment", kids)
    kids
  end
end
