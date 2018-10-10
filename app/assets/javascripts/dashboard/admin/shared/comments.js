var Comments = (function(){
  return {
    init: function(){
      var addList = document.querySelectorAll('.add_comment_btn');
      for(var i=0; i<addList.length; i++){
        var addBtn = addList[i];
        addBtn.addEventListener('click', function(event){
          event.preventDefault();
          event.target.closest('.comment_list_wrapper')
            .querySelector('.new_comment')
            .classList.remove('hidden');
        });
      };

      var editList = document.querySelectorAll('.edit_comment_btn');
      for(var j=0; j<editList.length; j++){
        var editBtn = editList[j];
        editBtn.addEventListener('click', function(event){
          event.preventDefault();
          var comment_body = event.target.closest('.body');
          comment_body.querySelector('.show').classList.add('hidden');
          comment_body.querySelector('.edit').classList.remove('hidden');
        });
      };

      var cancelList = document.querySelectorAll('.cancel_edit_comment_btn');
      for(var k=0; k<editList.length; k++){
        var cancelBtn = cancelList[k];
        cancelBtn.addEventListener('click', function(event){
          event.preventDefault();
          var comment_body = event.target.closest('.body');
          comment_body.querySelector('.show').classList.remove('hidden');
          comment_body.querySelector('.edit').classList.add('hidden');
        });
      };
    }
  };
})();
