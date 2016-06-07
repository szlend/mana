defmodule Mana.ErrorHelpers do
  @moduledoc """
  Conveniences for translating and building error messages.
  """

  use Phoenix.HTML

  @doc """
  Generates tag for inlined form input errors.
  """
  def error_tag(form, field) do
    if error = form.errors[field] do
      content_tag :span, translate_error(error), class: "help-block"
    end
  end

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    # Because error messages were defined within Ecto, we must
    # call the Gettext module passing our Gettext backend. We
    # also use the "errors" domain as translations are placed
    # in the errors.po file. On your own code and templates,
    # this could be written simply as:
    #
    #     dngettext "errors", "1 file", "%{count} files", count
    #
    Gettext.dngettext(Mana.Gettext, "errors", msg, msg, opts[:count], opts)
  end

  def translate_error(msg) do
    Gettext.dgettext(Mana.Gettext, "errors", msg)
  end

  def fieldset_tag(form, field, options, [do: block]) when is_list(options) do
    {error_class, options} = Keyword.pop(options, :error_class, "")
    case error_tag(form, field) do
      nil ->
        content_tag(:fieldset, block, options)
      error_tag ->
        options = fieldset_options_with_error(options, error_class)
        content_tag(:fieldset, [block, error_tag], options)
    end
  end

  defp fieldset_options_with_error(options, error_class) do
    {class, options} = Keyword.pop(options, :class)
    class = String.strip("#{class} #{error_class}")
    [{:class, class} | options]
  end
end
