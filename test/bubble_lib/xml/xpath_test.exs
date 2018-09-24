defmodule BubbleLib.XML.XPathTest do
  use ExUnit.Case
  import BubbleLib.XML.XPath

  test "XPATH selection" do
    assert "bas" = xml_xpath("<foo><bar>bas</bar></foo>", "/foo/bar/text()")
    assert ["a", "b"] = xml_xpath("<foo><bar>a</bar><bar>b</bar></foo>", "/foo/bar/text()")
  end

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

  test "Larger XML doc" do
    assert [["question", %{"code" => "e7irg9py"}, _]] =
             xml_xpath(@another_xml, "/profile/question[@code=\"e7irg9py\"]")
  end

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

  test "complicated XPath" do
    xml = BubbleLib.XML.xml_parse(@and_another_xml)
    assert "Overview" = xml_xpath(xml, "/slideshow/slide[2]/title/text()")
  end
end
