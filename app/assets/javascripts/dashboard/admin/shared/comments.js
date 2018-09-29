const Comments = (function(){
  return {
    init: function(){
      document.querySelectorAll('.add_comment_btn').forEach(function(btn){
        btn.addEventListener('click', function(event){
          event.preventDefault();
          event.target.closest('.comment_list_wrapper')
            .querySelector('.new_comment')
            .classList.remove('hidden');
        });
      });

      document.querySelectorAll('.edit_comment_btn').forEach(function(btn){
        btn.addEventListener('click', function(event){
          event.preventDefault();
          let comment_body = event.target.closest('.body');
          comment_body.querySelector('.show').classList.add('hidden');
          comment_body.querySelector('.edit').classList.remove('hidden');
        });
      });

      document.querySelectorAll('.cancel_edit_comment_btn').forEach(function(btn){
        btn.addEventListener('click', function(event){
          event.preventDefault();
          let comment_body = event.target.closest('.body');
          comment_body.querySelector('.show').classList.remove('hidden');
          comment_body.querySelector('.edit').classList.add('hidden');
        });
      });
    }
  };
})();
