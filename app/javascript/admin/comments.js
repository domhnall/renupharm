export default function(){
  let addList = document.querySelectorAll('.add_comment_btn');
  for(let i=0; i<addList.length; i++){
    let addBtn = addList[i];
    addBtn.addEventListener('click', function(event){
      event.preventDefault();
      event.target.closest('.comment_list_wrapper')
        .querySelector('.new_comment')
        .classList.remove('hidden');
    });
  };

  let editList = document.querySelectorAll('.edit_comment_btn');
  for(let j=0; j<editList.length; j++){
    let editBtn = editList[j];
    editBtn.addEventListener('click', function(event){
      event.preventDefault();
      let comment_body = event.target.closest('.body');
      comment_body.querySelector('.show').classList.add('hidden');
      comment_body.querySelector('.edit').classList.remove('hidden');
    });
  };

  let cancelList = document.querySelectorAll('.cancel_edit_comment_btn');
  for(let k=0; k<editList.length; k++){
    let cancelBtn = cancelList[k];
    cancelBtn.addEventListener('click', function(event){
      event.preventDefault();
      let comment_body = event.target.closest('.body');
      comment_body.querySelector('.show').classList.remove('hidden');
      comment_body.querySelector('.edit').classList.add('hidden');
    });
  };
};
