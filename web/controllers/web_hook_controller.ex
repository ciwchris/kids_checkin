defmodule KidsCheckin.WebHookController do
  use KidsCheckin.Web, :controller
  import Poison, only: [encode: 1]

  def index(conn, _params) do
    kids = LruCache.get(:my_cache, "kids") || setCache

    {status, classes} = encode KidsCheckin.CheckinParse.parse(kids, 1)

    KidsCheckin.Endpoint.broadcast("checkins:count", "count_update", %{classes: classes})
    json conn, classes
  end

  defp setCache() do
    kids = %{}
    LruCache.put(:my_cache, "kids", kids)
    kids
  end
end
