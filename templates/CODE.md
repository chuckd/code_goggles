# Code Reading for <%= @gem_name %> gem

## Code Stats

<%= @cloc_output %>

## Gemspec

```ruby
<%= @gemspec_content %>
```

## Code

<% for @filename, @content in @files %>
### <%= @filename %>

```ruby
<%= @content %>
```
<% end %>

## Specs

### ... read specs
