class CommentsController < ApplicationController
  def destroy
    @comment = Comment.find(params[:id])

    # この「if」の中身が、認可（権限チェック）のビジネスルールです。
    # ここを専用のクラスに追い出しましょう！
    if current_user.admin? || @comment.user_id == current_user.id
      @comment.destroy
      redirect_to post_path(@comment.post), notice: '削除しました'
    else
      # 権限がない場合
      redirect_to post_path(@comment.post), alert: '権限がありません'
    end
  end
end

# ----------------


class CommonPolicy
  def initializ(user, comment)
    @user = user
    @comment = comment
  end

  def destroy?
    user.admin? || commment.user_id == user.id
  end
end

class CommentController < ApplicationController
  def destroy
    @comment = Comment.find(params[:id])

    polisy = CommonPolicy.new(current_user, @comment)

    if polisy.destroy?
      @comment.destroyredirect_to post_path(@comment.post), notice: '削除しました'
    else
      redirect_to post_path(@comment.post), alert: '権限がありません'
    end
  end
end