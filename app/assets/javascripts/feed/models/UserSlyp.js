slypApp.Models.UserSlyp = Backbone.Model.extend({
  authorshipMeta: function(){
    if (this.get('author') && this.get('site_name')){
      return this.get('site_name') + ' | by ' + this.get('author')
    } else if (this.get('author')){
      return 'by ' + this.get('author')
    } else if (this.get('site_name')){
      return this.get('site_name')
    } else {
      return ''
    }
  }
})