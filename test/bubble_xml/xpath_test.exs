defmodule BubbleXml.XPathTest do
  use ExUnit.Case
  import BubbleXml.XPath

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
end
