<?xml version="1.0"?>

<xsl:stylesheet
    version="1.0"
    exclude-result-prefixes="atom"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:atom="http://www.w3.org/2005/Atom"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="html" omit-xml-declaration="yes" indent="no"/>

<xsl:template match="/">
<html>
<head>
	<link type="application/atom+xml" rel="alternate" href="{/atom:feed/atom:link[@rel='self']/@href}" title="{/atom:feed/atom:title}" />
	<meta name="generator" content="https://github.com/jameysharp/css-feed-reader" />
	<meta name="viewport" content="width=device-width" />
	<title><xsl:value-of select="/atom:feed/atom:title"/></title>
	<style>
		<xsl:text>
		body {
			position: absolute;
			width: 100%;
			height: 100%;
			margin: 0;
			display: flex;
			flex-direction: column;
		}
		#top, #left {
			margin: 0;
			padding: 0;
			box-sizing: border-box;
		}
		#top {
			width: 100%;
			background-color: black;
			color: white;
			display: flex;
			align-items: center;
			flex-shrink: 0;
			flex-grow: 0;
		}
		#top > * {
			flex-shrink: 0;
			flex-grow: 0;
		}
		#top img {
			background-color: #4A1600;
			padding: 0.5em;
			display: block;
		}
		#top label[for] img {
			background-color: #93320C;
		}
		#top label[for] img:hover {
			background-color: #4A1600;
		}
		#top > .title {
			flex-grow: 1;
			flex-shrink: 1;
			text-align: center;
			overflow: hidden;
			white-space: nowrap;
		}
		time {
			color: #DDD;
			font-size: 80%;
			display: block;
		}
		#left time {
			color: #555;
		}
		#left ul {
			padding: 0;
			margin: 1ex;
			list-style: none;
		}
		#left li {
			margin-bottom: 1ex;
		}
		#left {
			position: absolute;
			top: 0;
			left: -30%;
			height: 100%;
			background-color: #EEC;
			border: 2px solid black;
			overflow: auto;
			visibility: hidden;
			width: 30%;
			transition-property: visibility, left;
			transition-duration: 100ms;
		}
		#expand-sidebar:checked ~ #left {
			visibility: visible;
			left: 0;
		}
		#expand-sidebar-btn {
			padding: 3px;
			background-color: #EEC;
			color: black;
			font-size: 120%;
			margin-right: 1em;
			transition-property: margin;
			transition-duration: 100ms;
		}
		#expand-sidebar:checked ~ #top #expand-sidebar-btn {
			margin-left: 30%;
		}
		#content {
			flex-grow: 1;
		}
		#content * {
			width: 100%;
			height: 100%;
		}
		iframe {
			margin: 0;
			padding: 0;
			border: 0;
		}
		input, .preload {
			display: none;
		}</xsl:text>
		<xsl:apply-templates select="//atom:entry" mode="style" />
	</style>
</head>
<body>
	<input type="checkbox" id="expand-sidebar" />
	<xsl:apply-templates select="//atom:entry" mode="radio" />

	<div id="top">
		<label for="expand-sidebar" id="expand-sidebar-btn">&#187;</label>
		<xsl:apply-templates select="//atom:entry" mode="top" />
	</div>

	<div id="content">
		<noscript id="preloadContent">
		<xsl:apply-templates select="//atom:entry" mode="iframe" />
		</noscript>
	</div>

	<div id="left">
		<ul>
		<xsl:apply-templates select="//atom:entry" mode="left" />
		</ul>
	</div>

	<!-- progressive enhancements -->
	<script>
		(function() {
			var preloadContent = document.getElementById("preloadContent");

			// copy the noscript tag's contents into a new,
			// detached, div tag
			var contentParent = document.createElement("div");
			contentParent.innerHTML = preloadContent.innerHTML;

			// before attaching the div to the document, remove all
			// the src attributes so the iframes don't really load
			Array.prototype.forEach.call(document.getElementsByName("page"), function(page) {
				// but allow loading whichever page we're going
				// to display first
				if(page.checked)
					return;

				var iframe = contentParent.getElementsByClassName(page.id)[0];
				iframe.setAttribute("data-src", iframe.getAttribute("src"));
				iframe.removeAttribute("src");

				// the first time someone jumps to a page, load
				// its iframe contents
				page.addEventListener("change", function() {
					if(!iframe.hasAttribute("data-src"))
						return;
					iframe.setAttribute("src", iframe.getAttribute("data-src"));
					iframe.removeAttribute("data-src");
				}, { once: true });
			});

			// finally, replace the noscript tag with the fixed-up
			// div tag that contains all the iframes
			document.getElementById("content").replaceChild(contentParent, preloadContent);
		})();
	</script>
</body>
</html>
</xsl:template>

<xsl:template match="*" mode="style">
		#page<xsl:value-of select="position()"/>:checked ~ * .page<xsl:value-of select="position()"/> {
			display: block;
		}
		#page<xsl:value-of select="position()"/>:checked ~ #left label[for="page<xsl:value-of select="position()"/>"] {
			font-weight: bold;
		}<!--
--></xsl:template>

<xsl:template match="*" mode="radio">
	<input type="radio" name="page" id="page{position()}">
		<xsl:if test="position() = 1">
			<xsl:attribute name="checked">checked</xsl:attribute>
		</xsl:if>
	</input>
</xsl:template>

<xsl:template match="*" mode="top">
	<label class="preload page{position()}">
		<xsl:if test="position() &gt; 1">
			<xsl:attribute name="for">page<xsl:value-of select="position() - 1"/></xsl:attribute>
		</xsl:if>
		<img src="https://www.comic-rocket.com/media/img/icon-prevpage.png" />
	</label>
	<div class="preload page{position()} title">
		<xsl:value-of select="atom:title"/>
		<time datetime="{atom:published}">
			<xsl:value-of select="substring-before(atom:published, 'T')"/>
		</time>
	</div>
	<label class="preload page{position()}">
		<xsl:if test="position() &lt; last()">
			<xsl:attribute name="for">page<xsl:value-of select="position() + 1"/></xsl:attribute>
		</xsl:if>
		<img src="https://www.comic-rocket.com/media/img/icon-nextpage.png" />
	</label>
</xsl:template>

<xsl:template match="*" mode="iframe">
	<iframe class="preload page{position()}" src="{atom:link[@rel='alternate']/@href}"/>
</xsl:template>

<xsl:template match="*" mode="left">
	<li>
		<label for="page{position()}">
			<xsl:value-of select="atom:title"/>
			<time datetime="{atom:published}">
				<xsl:value-of select="substring-before(atom:published, 'T')"/>
			</time>
		</label>
	</li>
</xsl:template>

</xsl:stylesheet>
