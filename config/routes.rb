Rails.application.routes.draw do
  root to: "evaluation#index"

  resource :evaluation, only: [] do
    get :multicriteria, to: "evaluation#multicriteria"
    get :wsm, to: "evaluation#wsm"
  end
end
