//
//  XMLToMarkdownTests.swift
//  XMLToMarkdownTests
//
//  Distributed under the ISC license, see LICENSE.
//

import XCTest

class XMLToMarkdownTests: XCTestCase {

    private func issueTest(_ xml: String, _ expectMarkdown: String) {
        let parser = XMLToMarkdown()
        let discussionXml = "<Discussion>\(xml)</Discussion>"
        let actualMarkdown = parser.parseDiscussion(xml: discussionXml)
        XCTAssertEqual(actualMarkdown, expectMarkdown)
    }

    func testSimplePara() {
        let str = "Some text"
        issueTest("<Para>\(str)</Para>", str)
    }

    func testMultiplePara() {
        let str1 = "Some text"
        let str2 = "Some more text"
        issueTest("<Para>\(str1)</Para><Para>\(str2)</Para>", "\(str1)\n\n\(str2)")
    }

    func testEmphasis() {
        let str = "Emphasised"
        issueTest("<Para><emphasis>\(str)</emphasis></Para>", "*\(str)*")
    }

    func testStrong() {
        let str = "Strong"
        issueTest("<Para><strong>\(str)</strong></Para>", "**\(str)**")
    }

    func testFixed() {
        let str = "Fixed"
        issueTest("<Para><codeVoice>\(str)</codeVoice></Para>", "`\(str)`")
    }

    func testInlineEscapes() {
        let xmlStr = "`Str` __with__ *inside* it"
        let mdStr  = "\\`Str\\` \\_\\_with\\_\\_ \\*inside\\* it"
        issueTest("<Para>\(xmlStr)</Para>", mdStr)
    }

    func testBulletEscapes() {
        let xmlStr1 = "- this is not a bullet"
        let mdStr1 = "\\- this is not a bullet"
        let xmlStr2 = "1. neither is this"
        let mdStr2 = "1\\. neither is this"
        let xmlStr3 = "+ nor this"
        let mdStr3 = "\\+ nor this"
        issueTest("<Para>\(xmlStr1)</Para><Para>\(xmlStr2)</Para><Para>\(xmlStr3)</Para>",
                  "\(mdStr1)\n\n\(mdStr2)\n\n\(mdStr3)")
    }

    func testHeadingEscape() {
        let xmlStr = "## this is not a heading ##"
        let mdStr  = "\\#\\# this is not a heading \\#\\#"
        issueTest("<Para>\(xmlStr)</Para>", mdStr)
    }

    func testSimpleCodeBlock() {
        let code = "   This is code"
        issueTest("<CodeListing><![CDATA[\(code)]]></CodeListing>", "```\n\(code)\n```")
    }

    func testLingualCodeBlock() {
        let code = "   This is code"
        let language = "esperanto"
        issueTest("<CodeListing language=\"\(language)\"><![CDATA[\(code)]]></CodeListing>", "```\(language)\n\(code)\n```")
    }

    func testActualCodeBlock() {
        let code1 = "   This is code"
        let code2 = "This is line2"
        let language = "swift"

        issueTest(
            "<Document><CodeListing language=\"\(language)\">" +
                "<zCodeLineNumbered><![CDATA[\(code1)]]></zCodeLineNumbered>" +
                "<zCodeLineNumbered><![CDATA[\(code2)]]></zCodeLineNumbered>" +
            "</CodeListing></Document>",
            "```\(language)\n" +
                "\(code1)\n" +
                "\(code2)\n" +
            "```")
    }

    func testInlineHTML() {
        let text1 = "I like "
        let html1 = "<span style=\"fishy\">"
        let text2 = "plaice"
        let html2 = "</span>"

        issueTest(
            "<Para>\(text1)" +
                "<rawHTML><![CDATA[\(html1)]]></rawHTML>" +
                "\(text2)" +
                "<rawHTML><![CDATA[\(html2)]]></rawHTML>" +
            "</Para>",
            "\(text1)\(html1)\(text2)\(html2)")
    }

    func testBlockHTML() {
        let para1 = "Normal text"
        let html  = "<div>Unusual area</div>"
        let para2 = "More normal text"

        issueTest(
            "<Para>\(para1)</Para>" +
                "<rawHTML><![CDATA[\(html)]]></rawHTML>" +
            "<Para>\(para2)</Para>",
            "\(para1)\n" +
                "\n" +
                "\(html)\n" +
                "\n" +
            "\(para2)")
    }
    
    func testLink() {
        let text = "This is text"
        let link = "http://example.com"
        issueTest(
            "<Link href=\"\(link)\">\(text)</Link>",
            "[\(text)](\(link))")
    }

    func testImageLinkOnly() {
        let url = "http://example.com/"
        issueTest(
            "<rawHTML><![CDATA[<img src=\"\(url)\"/>]]></rawHTML>",
            "![](\(url))")
    }

    func testImageLinkAndAltText() {
        let url = "http://example.com/"
        let alt = "A nice link"
        issueTest(
            "<rawHTML><![CDATA[<img src=\"\(url)\" alt=\"\(alt)\"/>]]></rawHTML>",
            "![\(alt)](\(url))")
    }

    func testImageLinkAndTitle() {
        let url = "http://example.com/"
        let title = "Hovertext"
        issueTest(
            "<rawHTML><![CDATA[<img src=\"\(url)\" title=\"\(title)\"/>]]></rawHTML>",
            "![](\(url) \"\(title)\")")
    }

    func testImageLinkAltTextAndTitle() {
        let url = "http://example.com/"
        let alt = "A nice link"
        let title = "Hovertext"
        issueTest(
            "<rawHTML><![CDATA[<img src=\"\(url)\" title=\"\(title)\" alt=\"\(alt)\"/>]]></rawHTML>",
            "![\(alt)](\(url) \"\(title)\")")
    }

    func testHorzRule() {
        issueTest(
            "<rawHTML><![CDATA[<hr/>]]></rawHTML>",
            "---")
    }

    func testSimpleHeadings() {
        let heading = "Heading Title"

        issueTest(
            "<rawHTML><![CDATA[<h1>]]></rawHTML>\(heading)<rawHTML><![CDATA[</h1>]]></rawHTML>",
            "# \(heading)")

        issueTest(
            "<rawHTML><![CDATA[<h2>]]></rawHTML>\(heading)<rawHTML><![CDATA[</h2>]]></rawHTML>",
            "## \(heading)")

        issueTest(
            "<rawHTML><![CDATA[<h3>]]></rawHTML>\(heading)<rawHTML><![CDATA[</h3>]]></rawHTML>",
            "### \(heading)")

        issueTest(
            "<rawHTML><![CDATA[<h4>]]></rawHTML>\(heading)<rawHTML><![CDATA[</h4>]]></rawHTML>",
            "#### \(heading)")

        issueTest(
            "<rawHTML><![CDATA[<h5>]]></rawHTML>\(heading)<rawHTML><![CDATA[</h5>]]></rawHTML>",
            "##### \(heading)")
    }

    func testHeadingAndText() {
        let heading = "Heading text"
        let para1 = "Para 1 text"
        let para2 = "Para 2 text"

        issueTest(
            "<Para>\(para1)</Para>" +
            "<rawHTML><![CDATA[<h2>]]></rawHTML>\(heading)<rawHTML><![CDATA[</h2>]]></rawHTML>" +
            "<Para>\(para2)</Para>",
            "\(para1)\n" +
            "\n" +
            "## \(heading)\n" +
            "\n" +
            "\(para2)")
    }

    func testSimpleBullets() { // custom list numbering, change lists on bullet type
        XCTFail()
    }
    
    func testNestedBullets() {
        XCTFail()
    }
    
    func testNestedParas() {
        XCTFail()
    }
    
    func testNestedCodeBlock() {
        XCTFail()
    }
    
    func testUnknownElement() {
        XCTFail()
    }
}
