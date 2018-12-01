function detectFeed(event) {
	for (var header of event.responseHeaders) {
		if (header.name.toLowerCase() == "content-type" && /application\/((rss|atom)\+)?xml/.test(header.value)) {
			header.value = header.value.replace(/application\/(rss|atom)\+xml/, 'application/xml');
			let filter = browser.webRequest.filterResponseData(event.requestId);
			let decoder = new TextDecoder("utf-8");
			let encoder = new TextEncoder();
			let base = browser.runtime.getURL("");
			let isfeed = false;

			filter.ondata = event => {
				if(!isfeed) {
					let str = decoder.decode(event.data, {stream: true});
					str = str.replace(/<(atom:)?feed[> \t\r\n]/, function(match) {
						isfeed = true;
						return '<?xml-stylesheet href="' + base + 'reader.xsl" type="text/xsl"?><?xslt-param name="iconpath" value="' + base + '"?><wrapper>' + match;
					});
					filter.write(encoder.encode(str));
				} else {
					filter.write(event.data);
				}
			}
			filter.onstop = event => {
				if(isfeed)
					filter.write(encoder.encode("</wrapper>"));
				filter.disconnect();
			}

			return {
				responseHeaders: event.responseHeaders
			};
		}
	}
}

browser.webRequest.onHeadersReceived.addListener(
	detectFeed,
	{ urls: ["<all_urls>"], types: ["main_frame"] },
	["blocking", "responseHeaders"]
)
