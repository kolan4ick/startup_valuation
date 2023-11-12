Rails.application.routes.draw do
  root to: "evaluation#index"

  resource :evaluation, only: [] do
    get :effectiveness, to: "evaluation#effectiveness"
    get :risk, to: "evaluation#risk"
  end
end
