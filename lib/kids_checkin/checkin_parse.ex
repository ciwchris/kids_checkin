defmodule KidsCheckin.CheckinParse do
  import Poison, only: [decode: 1]

  def parse(kids \\ %{}, page \\ 1) do
    case Mix.env do
      :prod -> liveResults kids, page
      _ -> testResults kids, page
    end
  end

  defp liveResults(kids, page) do
    newKids = Enum.filter(getCheckinsPage(page), fn checkin -> isToday(checkin["checked_in_at"], checkin["event"]["title"]) end)

    cond do
      Enum.count(newKids) == 0 -> updateCache kids
      !Map.has_key?(kids, hd(Enum.reverse newKids)["barcode"]) -> parse(mapKids(newKids, kids), (page + 1))
      true -> updateCache mapKids(newKids, kids)
    end
  end

  defp mapKids(newKids, kids) do 
    Enum.reduce(newKids, kids, fn(checkin, acc) -> Map.put_new(acc, checkin["barcode"], checkin["group"]["id"]) end)
  end

  defp updateCache(newKids) do
    LruCache.update(:my_cache, "kids", newKids, touch = false)
    formatKids(newKids)
  end

  defp testResults(kids, page) do
    test = """
    [
    {"group":{"id":108123},"barcode":"9C002D3D64"},
    {"group":{"id":89515},"barcode":"6C002D3D64"}
    ]
    """
    {_, checkins} = decode test

    newKids = mapKids(checkins, kids)
    LruCache.update(:my_cache, "kids", newKids, touch = false)
    formatKids(newKids)
  end

  defp getCheckinsPage(page) do
    url = "https://api.onthecity.org/checkins?page=" <> to_string(page)
    time = :os.system_time(:milli_seconds)
    signed = :crypto.hmac(:sha256, Application.get_env(:kids_checkin, :thecity_secret_key), "#{time}GET#{url}") |> Base.encode64 |> URI.encode_www_form
    response = HTTPoison.get!(url, [{"X-City-Sig", signed}, {"X-City-User-Token", Application.get_env(:kids_checkin, :thecity_user_token)},{"X-City-Time", time},{"Accept", "application/vnd.thecity.admin.v1+json"}])
    {_, checkins} = decode response.body
    checkins["checkins"]
  end

  def formatKids(kids) do
    adjustment = LruCache.get(:my_cache, "adjustment") || %{}
    [
      %{"id" => 108117, "color" => "red", "count" => getCounts(kids, adjustment, 108117), "max" => 12, "name" => "Nursery"},
      %{"id" => 108119, "color" => "orange", "count" => getCounts(kids, adjustment, 108119), "max" => 12, "name" =>  "Toddlers"},
      %{"id" => 108120, "color" => "yellow", "count" => getCounts(kids, adjustment, 108120), "max" => 12, "name" =>  "Preschool #1"},
      %{"id" => 144673, "color" => "green", "count" => getCounts(kids, adjustment, 144673), "max" => 12, "name" =>  "Preschool # 2"},
      %{"id" => 108123, "color" => "blue", "count" => getCounts(kids, adjustment, 108123), "max" => 16, "name" =>  "Primary"},
      %{"id" => 89515, "color" => "purple", "count" => getCounts(kids, adjustment, 89515), "max" => 16, "name" => "Elementary"},
      %{"id" => 108123, "color" => "combined", "count" => getCounts(kids, adjustment, 108123) + getCounts(kids, adjustment, 89515), "max" => 20, "name" =>  "Combined"},
    ]
  end

  defp getCounts(kids, adjustment, id) do
    (Enum.filter(Map.values(kids), fn kid -> kid == id end) |> Enum.count) + (Enum.filter(Map.values(adjustment), fn kid -> kid == id end) |> Enum.count)
  end

  defp isToday(startingDate, title) do
    now = Timex.Date.local
    {_, fstart} = startingDate |> Timex.DateFormat.parse("{M}/{D}/{YYYY} {h12}:{m} {AM} ({Zname})")
    fstart.day == now.day && title == "Sunday Gathering"
  end

end

# case response do
#   {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
#     IO.puts body
#   {:ok, %HTTPoison.Response{status_code: 404}} ->
#     IO.puts "Not found :("
#   {:error, %HTTPoison.Error{reason: reason}} ->
#     IO.inspect reason
# end
