#= require views/pages/base

class app.views.MallardPage extends app.views.BasePage
  afterRender: ->
    @highlightCode @findAll('code[language="c"]'), 'c'
    @highlightCode @findAll('pre.contents'), 'javascript'
    return

app.views.GObjectPage =
app.views.GtkPage =
app.views.MallardPage
