return {
  "nvim-treesitter/nvim-treesitter",
  opts = function(_, opts)
    -- add more things to the ensure_installed table protecting against community packs modifying it
    opts.ensure_installed = require("astronvim.utils").list_insert_unique(opts.ensure_installed, {
      "lua", "nix", "bash", "python", "html", "json", "dockerfile", "css", "javascript", "sql", "markdown", "yaml", "xml", "ssh_config"
    })
  end, 
} 
