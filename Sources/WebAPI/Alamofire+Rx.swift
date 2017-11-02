import Alamofire
import RxSwift
import Foundation

extension Request: ReactiveCompatible {}

extension Reactive where Base: DataRequest {

  func responseData() -> Observable<Data> {
    return Observable.create { observer in
      let request = self.base.responseData { response in
        switch response.result {
        case .success(let value):
          observer.onNext(value)
          observer.onCompleted()

        case .failure(let error):
          observer.onError(error)
        }
      }

      return Disposables.create(with: request.cancel)
    }
  }

  func responseJSON() -> Observable<Any> {
    return Observable.create { observer in
      let request = self.base.responseJSON { response in
        switch response.result {
        case .success(let value):
          observer.onNext(value)
          observer.onCompleted()

        case .failure(let error):
          observer.onError(error)
        }
      }

      return Disposables.create(with: request.cancel)
    }
  }

}
