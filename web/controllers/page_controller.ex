defmodule KidsCheckin.PageController do
  use KidsCheckin.Web, :controller

  def index(conn, _params) do
    kids = LruCache.get(:my_cache, "kids") || %{}
    render conn, "index.html", classes: KidsCheckin.CheckinParse.formatKids(kids)
  end

  def combined(conn, _params) do
    kids = LruCache.get(:my_cache, "kids") || %{}
    render conn, "combined.html", classes: KidsCheckin.CheckinParse.formatKids(kids)
  end

  def counts(conn, _params) do
    kids = LruCache.get(:my_cache, "kids") || %{}
    render conn, "counts.html", classes: KidsCheckin.CheckinParse.formatKids(kids)
  end
end
