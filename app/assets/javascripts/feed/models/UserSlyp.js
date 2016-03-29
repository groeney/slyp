slypApp.Models.UserSlyp = Backbone.Model.extend({
  moveToFront: function() {
    this.collection.moveToFront(this);
  },
  moveToBack: function(){
    this.collection.moveToBack(this);
  },
  displayTitle: function(){
    return this.get('title') ? this.get('title') : this.get('url')
  },
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