defmodule BubbleXml.ParseTest do
  use ExUnit.Case

  import BubbleXml.Parse

  @pairs [
    {"<foo/>", ["foo", %{}, []]},
    {"<foo a=\"b\"/>", ["foo", %{"a" => "b"}, []]},
    {"<foo><bar/></foo>", ["foo", %{}, [["bar", %{}, []]]]},
    {"<foo><bar/><bar/></foo>", ["foo", %{}, [["bar", %{}, []], ["bar", %{}, []]]]},
    {"<foo><bar>bas</bar><bar b=\"2\"/></foo>",
     ["foo", %{}, [["bar", %{}, "bas"], ["bar", %{"b" => "2"}, []]]]}
  ]

  test "parsing" do
    for {source, expected} <- @pairs do
      assert expected == xml_parse(source)
    end
  end

  @complicated_xml ~s(
<visitor code="2eojpc4ti97yk" self="/visitors/2eojpc4ti97yk" revision="6634395099">
    <reference>4fa27d01543df62a21a9251234f8d3f2</reference>
    <registrant-state>registered</registrant-state>
    <attendance-state>no-show</attendance-state>
    <actioncode/>
    <mailing/>
    <datause1/>
    <datause2/>
    <datause3/>
    <method>online</method>
    <register-time>2018-09-24 07:51:28</register-time>
    <visit-time/>
    <first-entry-time/>
    <dwelling-time/>
    <last-exit-time/>
    <registration-url>https://registration.n200.com/survey/2jzez16e8cbtv/start?translation=0xhss20yfe5wr&amp;visitor-contact=0lbd73n8s4xg5</registration-url>
    <event code="0ylinyz4wetfl" link="/events/0ylinyz4wetfl" />
    <registration-type code="1yga2gn8a" link="/registration-types/1yga2gn8a" />
    <form code="2jzez16e8cbtv" link="/forms/2jzez16e8cbtv" />
    <translation code="0xhss20yfe5wr" link="/translations/0xhss20yfe5wr" language="Dutch, Flemish" iso="NL" />
    <contact code="0lbd73n8s4xg5" link="/contacts/0lbd73n8s4xg5" />
    <profile code="2eojpc4ti97yk" link="/visitor-profiles/2eojpc4ti97yk" />
    <orders>
        <order code="5775932" link="/orders/1ywxgkz34" />
    </orders>
    <order code="5775932" link="/orders/1ywxgkz34" />
    <partner/>
    <visits>0</visits>
    <tags/>
    <policies>
        <policy type="privacy" checked="true" time="2018-09-24 07:51:26" />
        <policy type="stop-processing" checked="false" />
    </policies>
  </visitor>
  )

  test "complicated xml" do
    parsed = xml_parse(@complicated_xml)
    assert ["visitor", %{"code" => _}, [_ | _]] = parsed
  end
end
