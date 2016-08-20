exports.config = {
  files: {
    javascripts: {
      joinTo: {
        "js/app.js": /^(web\/static\/js)/,
        "js/vendor.js": /^(deps|node_modules)/
      }
    },
    stylesheets: {
      joinTo: {
        "css/app.css": /^(web\/static\/css)/,
        "css/vendor.css": /^(deps|node_modules)/
      }
    },
    templates: {
      joinTo: "js/app.js"
    }
  },

  conventions: {
    assets: /^(web\/static\/assets)/
  },

  paths: {
    watched: [
      "web/static",
      "test/static"
    ],
    public: "priv/static"
  },

  plugins: {
    babel: {
      ignore: [/web\/static\/vendor/]
    }
  },

  modules: {
    autoRequire: {
      "js/app.js": ["web/static/js/app"]
    }
  },

  npm: {
    enabled: true,
    whitelist: ["phoenix", "phoenix_html", "pixi.js", "rx-lite-dom-events"],
    styles: {
      bootstrap: ['dist/css/bootstrap.css']
    }
  }
};
