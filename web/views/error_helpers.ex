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
      content_tag(:span, translate_error(error), class: "help-block")
    end
  end

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    # Because error messages were defined within Ecto, we must
    # call the Gettext module passing our Gettext backend. We
    # also use the "errors" domain as translations are placed
    # in the errors.po file.
    # Ecto will pass the :count keyword if the error message is
    # meant to be pluralized.
    # On your own code and templates, depending on whether you
    # need the message to be pluralized or not, this could be
    # written simply as:
    #
    #     dngettext "errors", "1 file", "%{count} files", count
    #     dgettext "errors", "is invalid"
    #
    if count = opts[:count] do
      Gettext.dngettext(Mana.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(Mana.Gettext, "errors", msg, opts)
    end
  end

  def fieldset_tag(form, field, [do: block]) do
    fieldset_tag(form, field, [], [do: block])
  end

  def fieldset_tag(form, field, options, [do: block]) when is_list(options) do
    {error_class, options} = Keyword.pop(options, :error_class, "")
    if tag = error_tag(form, field) do
      options = fieldset_options_with_error(options, error_class)
      content_tag(:fieldset, [block, tag], options)
    else
      content_tag(:fieldset, block, options)
    end
  end

  defp fieldset_options_with_error(options, error_class) do
    {class, options} = Keyword.pop(options, :class)
    class = String.strip("#{class} #{error_class}")
    [{:class, class} | options]
  end
end
