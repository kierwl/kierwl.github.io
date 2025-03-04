module Jekyll
  class TagPageGenerator < Generator
    safe true

    def generate(site)
      site.tags.each do |tag, posts|
        site.pages << TagPage.new(site, tag, posts)
      end
    end
  end

  class TagPage < Page
    def initialize(site, tag, posts)
      @site = site
      @base = site.source
      @dir  = "tag/#{tag.slugify}"
      @name = "index.html"

      self.process(@name)
      self.read_yaml(File.join(@base, "_layouts"), "tag.html")
      self.data["tag"] = tag
      self.data["title"] = "Tag: #{tag}"
      self.data["posts"] = posts
    end
  end
end
