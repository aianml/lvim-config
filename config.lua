-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny

require "keymaps"

lvim.plugins = {
  -- color scheme
  { "EdenEast/nightfox.nvim" },
  -- git blame
  {
    "f-person/git-blame.nvim",
    event = "BufRead",
    config = function()
      vim.cmd "highlight default link gitblame SpecialComment"
      vim.g.gitblame_enabled = 0
      vim.g.gitblame_message_template = "<date>•[<author>]•<summary>"
      vim.g.gitblame_date_format = "(%a)%d-%b-%y %H:%M"
      vim.g.gitblame_display_virtual_text = 1
    end,
  },
  -- for python environment switching
  { "AckslD/swenv.nvim" },
  { "stevearc/dressing.nvim" },
  -- for python testing
  { "mfussenegger/nvim-dap-python" },
  { "nvim-neotest/neotest" },
  { "nvim-neotest/neotest-python" },
  -- for java
  { "mfussenegger/nvim-jdtls" },
  -- rust
  { "saecki/crates.nvim" }
}

-- Color
lvim.colorscheme = "nordfox"

-- Toggleterm 
lvim.builtin["terminal"].direction = "horizontal"

-- -- -- --
-- PYTHON .
-- -- -- --
-- declare formatters and linters
local formatters = require "lvim.lsp.null-ls.formatters"
formatters.setup { { name = "black" }, }

local linters = require "lvim.lsp.null-ls.linters"
linters.setup { { command = "flake8", filetypes = { "python" } } }


-- switching python enviromnent
lvim.builtin.which_key.mappings["C"] = {
  name = "Python",
  c = { "<cmd>lua require('swenv.api').pick_venv()<cr>", "Choose Env" },
}

-- pytest with DAP
lvim.builtin.dap.active = true
local mason_path = vim.fn.glob(vim.fn.stdpath "data" .. "/mason/")
pcall(function()
 require("dap-python").setup(mason_path .. "packages/debugpy/venv/bin/python")
end)

-- -- --
-- JAVA.
-- -- --

-- disable builtin jdtls support
vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "jdtls" })


-- Treesitter syntax
lvim.builtin.treesitter.ensure_installed = {
  "python",
  "java",
  "rust",
}

-- Configure neotest DAP 
require("neotest").setup({
  adapters = {
    require("neotest-python")({
      dap = {
        justMyCode = false,
        console = "integratedTerminal",
      },
      args = { "--log-level", "DEBUG", "--quiet" },
      runner = "pytest",
    })
  }
})

lvim.builtin.which_key.mappings["dm"] = {
  "<cmd>lua require('neotest').run.run()<cr>",
  "Test Method"
}
lvim.builtin.which_key.mappings["dM"] = {
  "<cmd>lua require('neotest').run.run({strategy = 'dap'})<cr>",
  "Test Method DAP"
}
lvim.builtin.which_key.mappings["df"] = {
  "<cmd>lua require('neotest').run.run({vim.fn.expand('%')})<cr>",
  "Test Class"
}
lvim.builtin.which_key.mappings["dF"] = {
  "<cmd>lua require('neotest').run.run({vim.fn.expand('%'), strategy = 'dap'})<cr>",
  "Test Class DAP"
}
lvim.builtin.which_key.mappings["dS"] = {
  "<cmd>lua require('neotest').summary.toggle()<cr>",
  "Test Summary"
}

-- hover cmp formatting: use BOTH icons and text name
lvim.builtin.cmp.formatting.format = function(entry, vim_item)
  local max_width = lvim.builtin.cmp.formatting.max_width
  if max_width ~= 0 and #vim_item.abbr > max_width then
    vim_item.abbr = string.sub(vim_item.abbr, 1, max_width - 1) .. lvim.icons.ui.Ellipsis
  end
  local kind_name = vim_item.kind --this is new
  if lvim.use_icons then
    vim_item.kind = lvim.builtin.cmp.formatting.kind_icons[vim_item.kind]

    if entry.source.name == "copilot" then
      vim_item.kind = lvim.icons.git.Octoface
      vim_item.kind_hl_group = "CmpItemKindCopilot"
    end

    if entry.source.name == "cmp_tabnine" then
      vim_item.kind = lvim.icons.misc.Robot
      vim_item.kind_hl_group = "CmpItemKindTabnine"
    end

    if entry.source.name == "crates" then
      vim_item.kind = lvim.icons.misc.Package
      vim_item.kind_hl_group = "CmpItemKindCrate"
    end

    if entry.source.name == "lab.quick_data" then
      vim_item.kind = lvim.icons.misc.CircuitBoard
      vim_item.kind_hl_group = "CmpItemKindConstant"
    end

    if entry.source.name == "emoji" then
      vim_item.kind = lvim.icons.misc.Smiley
      vim_item.kind_hl_group = "CmpItemKindEmoji"
    end

    vim_item.kind = string.format("%s %s", vim_item.kind, kind_name) -- this is the magic line
  end
  vim_item.menu = lvim.builtin.cmp.formatting.source_names[entry.source.name]
  vim_item.dup = lvim.builtin.cmp.formatting.duplicates[entry.source.name]
    or lvim.builtin.cmp.formatting.duplicates_default
  return vim_item
end

