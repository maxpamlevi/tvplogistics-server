SitemapGenerator::Sitemap.default_host = "https://tvplogistics.com.vn"
SitemapGenerator::Sitemap.compress = false
SitemapGenerator::Sitemap.create do
  # Static pages
  add '/', changefreq: 'daily', priority: 0.9
  add '/page-about-us', changefreq: 'monthly', priority: 0.7
  add '/page-pricing', changefreq: 'monthly', priority: 0.7
  add '/page-faq', changefreq: 'monthly', priority: 0.7
  add '/page-contact', changefreq: 'monthly', priority: 0.7
  add '/page-news', changefreq: 'weekly', priority: 0.8
  add '/page-logistics-service', changefreq: 'monthly', priority: 0.7
  add '/page-leadership', changefreq: 'monthly', priority: 0.7
  add '/page-careers', changefreq: 'monthly', priority: 0.7

  # Dynamic pages
  add '/contact', changefreq: 'monthly', priority: 0.7
  add '/logistics_service', changefreq: 'monthly', priority: 0.7
  add '/pricing', changefreq: 'monthly', priority: 0.7
  add '/faq', changefreq: 'monthly', priority: 0.7
  add '/about_us', changefreq: 'monthly', priority: 0.7
  add '/careers', changefreq: 'monthly', priority: 0.7
end