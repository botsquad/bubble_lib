defmodule BubbleLib.XML.ParseTest do
  use ExUnit.Case

  import BubbleLib.XML.Parse

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

  @another_xml ~s(
    <profile code="2eojpc4ti97yk" self="/visitor-profiles/2eojpc4ti97yk">
  <question code="e7irg9py" link="/questions/e7irg9py">
  <answer code="e7irgilt"/>
  </question>
  <question code="e95b2mq9" link="/questions/e95b2mq9">
  <answer code="e95b3474"/>
  </question>
  <question code="1ylm2o1h7" link="/questions/1ylm2o1h7">
  <answer code="1ylm2q66s"/>
  </question>
  <question code="1ywi4r7i2" link="/questions/1ywi4r7i2">
  <answer code="1ywi4xirv"/>
  </question>
  <question code="1ywvq7cne" link="/questions/1ywvq7cne">
  <answer code="1ywvqduh1"/>
  </question>
  <question code="1ywvq7cng" link="/questions/1ywvq7cng">
  <answer code="1ywvqduh6"/>
  </question>
  <question code="1ywvq7cnj" link="/questions/1ywvq7cnj">
  <answer code="1ywvqduhg">
  <value>gg</value>
  </answer>
  </question>
  </profile>
  )

  @and_another_xml ~s(<?xml version='1.0' encoding='us-ascii'?>

                                                    <!--  A SAMPLE set of slides  -->

    <slideshow
    title="Sample Slide Show"
    date="Date of publication"
    author="Yours Truly"
    >
  <?xml-stylesheet type="text/css" href="test.css"?>

     <!-- TITLE SLIDE -->
    <slide type="all">
  <title>Wake up to WonderWidgets!</title>
  </slide>

  <!-- OVERVIEW -->
    <slide type="all">
  <title>Overview</title>
  <item>Why <em>WonderWidgets</em> are great</item>
  <item/>
  <item>Who <em>buys</em> WonderWidgets</item>
  </slide>

  </slideshow>  )

  test "complicated xml" do
    parsed = xml_parse(@complicated_xml)
    assert ["visitor", %{"code" => _}, [_ | _]] = parsed
    assert ["profile", %{"code" => _}, [_ | _]] = xml_parse(@another_xml)
    assert ["slideshow", %{}, [_ | _]] = xml_parse(@and_another_xml)
  end

  test "CDATA" do
    assert ["profile", %{}, ">.<"] = xml_parse("<profile><![CDATA[>.<]]></profile>")
  end

  test "unescaping" do
    assert ["foo", %{"bar" => "&<>"}, "foo&bar"] ==
             xml_parse("<foo bar=\"&amp;&lt;&gt;\">foo&amp;bar</foo>")
  end

  test "internals" do
    assert "d" = BubbleLib.XML.Parse.simple_content([xmlText(value: "d")])

    x = [
      {:xmlElement, :slide, [], [], {:xmlNamespace, [], []}, [], :undefined,
       [{:xmlAttribute, :type, [], [], [], [], :undefined, [], "all", :undefined}],
       [
         {:xmlElement, :title, [], [], {:xmlNamespace, [], []}, [], :undefined, [],
          [{:xmlText, [], :undefined, [], "Wake up to WonderWidgets!", :text}], [], [],
          :undeclared}
       ], [], [], :undeclared},
      {:xmlElement, :slide, [], [], {:xmlNamespace, [], []}, [], :undefined,
       [{:xmlAttribute, :type, [], [], [], [], :undefined, [], "all", :undefined}],
       [
         {:xmlElement, :title, [], [], {:xmlNamespace, [], []}, [], :undefined, [],
          [{:xmlText, [], :undefined, [], "Overview", :text}], [], [], :undeclared},
         {:xmlElement, :item, [], [], {:xmlNamespace, [], []}, [], :undefined, [],
          [
            [{:xmlText, [], :undefined, [], "Why", :text}],
            {:xmlElement, :em, [], [], {:xmlNamespace, [], []}, [], :undefined, [],
             [{:xmlText, [], :undefined, [], "WonderWidgets", :text}], [], [], :undeclared},
            [{:xmlText, [], :undefined, [], "are great", :text}]
          ], [], [], :undeclared},
         {:xmlElement, :item, [], [], {:xmlNamespace, [], []}, [], :undefined, [], [], [], [],
          :undeclared},
         {:xmlElement, :item, [], [], {:xmlNamespace, [], []}, [], :undefined, [],
          [
            [{:xmlText, [], :undefined, [], "Who", :text}],
            {:xmlElement, :em, [], [], {:xmlNamespace, [], []}, [], :undefined, [],
             [{:xmlText, [], :undefined, [], "buys", :text}], [], [], :undeclared},
            [{:xmlText, [], :undefined, [], "WonderWidgets", :text}]
          ], [], [], :undeclared}
       ], [], [], :undeclared}
    ]

    assert [_, _] = BubbleLib.XML.Parse.simple_content(x)
  end
end
