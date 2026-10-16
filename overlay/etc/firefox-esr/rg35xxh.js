// RG35XX H (1 GB RAM) Firefox defaults. Users can still change these in about:config.
// Fewer processes: biggest memory saving with several tabs open.
pref("dom.ipc.processCount", 2);
pref("dom.ipc.processCount.webIsolated", 1);
pref("fission.autostart", false);
pref("browser.tabs.unloadOnLowMemory", true);
pref("browser.sessionhistory.max_total_viewers", 0);
pref("browser.cache.memory.capacity", 32768);
pref("browser.sessionstore.interval", 60000);
// YouTube etc.: H.264 instead of VP9/AV1 (cheaper to decode on the CPU, no HW decode yet).
pref("media.av1.enabled", false);
pref("media.mediasource.webm.enabled", false);
// No background traffic / prefetching.
pref("network.prefetch-next", false);
pref("network.dns.disablePrefetch", true);
pref("network.predictor.enabled", false);
pref("extensions.pocket.enabled", false);
pref("browser.newtabpage.activity-stream.feeds.topsites", false);
pref("browser.newtabpage.activity-stream.feeds.section.topstories", false);
pref("datareporting.healthreport.uploadEnabled", false);
pref("datareporting.policy.dataSubmissionEnabled", false);
pref("toolkit.telemetry.enabled", false);
pref("app.shield.optoutstudies.enabled", false);
// Enable add-ons installed system-wide by Debian packages (uBlock Origin) without a prompt.
pref("extensions.autoDisableScopes", 3);
