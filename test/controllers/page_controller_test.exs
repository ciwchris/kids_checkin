defmodule KidsCheckin.PageControllerTest do
  use KidsCheckin.ConnCase

  test "all classes displayed and open", %{conn: conn} do
    conn = get conn, "/"

    assert html_response(conn, 200) =~ "red\">Open"
    assert html_response(conn, 200) =~ "orange\">Open"
    assert html_response(conn, 200) =~ "yellow\">Open"
    assert html_response(conn, 200) =~ "green\">Open"
    assert html_response(conn, 200) =~ "blue\">Open"
    assert html_response(conn, 200) =~ "purple\">Open"
  end

  test "all classes displayed with count", %{conn: conn} do
    conn = get conn, "/counts"

    assert html_response(conn, 200) =~ "red\">0"
    assert html_response(conn, 200) =~ "orange\">0"
    assert html_response(conn, 200) =~ "yellow\">0"
    assert html_response(conn, 200) =~ "green\">0"
    assert html_response(conn, 200) =~ "blue\">0"
    assert html_response(conn, 200) =~ "purple\">0"
  end

  test "class displays count with kids checked in", %{conn: conn} do
    IO.puts "starting test"
    LruCache.update(:my_cache, "kids", %{"color" => "purple", "count" => 1})
    conn = get conn, "/counts"

    #%{"color" => "purple", "count" => 0, "id" => 89515, "max" => 16,"name" => "Elementary"}]

    assert html_response(conn, 200) =~ "purple\">1"
  end

end
