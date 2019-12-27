//
//  ViewController.swift
//  RxSwift_Practice
//
//  Created by ShawnHuang on 2019/12/17.
//  Copyright © 2019 ShawnHuang. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
class ViewController: UIViewController {
    
/*
    可觀察序列 - Observable
    觀察者 - Observer
    調度者 - Scheduler
    銷毀者 - Dispose
 */
    @IBOutlet weak var testBtn: UIButton!
    @IBOutlet weak var testField: UITextField!
    @IBOutlet weak var testLabel: UILabel!
    
    let disposeBag = DisposeBag()
    let err = NSError(domain: "errorDomain", code: 123, userInfo: ["test":"error"])
    override func viewDidLoad() {
        
        super.viewDidLoad()
        Observable_Type()
        Subject_Type()
        
//        Observable序列的創建方式()
        高階函數_組合操作符()
        高階函數_映射操作符()
//        高階函數_過濾條件操作符()
//        高階函數_集合控制操作符ㄧ()
//        高階函數_集合控制操作符二()
        
        let ob = Observable.of("xxx","aaa")
        let a = testLabel.rx.text.asObserver()
        ob.subscribe({ str in
            print(str)
        })
        ob.bind { str in
            print(str)
        }
        
    }
//MARK: - Observable 類型
    func Observable_Type()
    {
        
        
        //MARK:  Observable 隨意產生
        print("********Observable********")
        let ob = Observable<String>.create { (obs) -> Disposable in
            
            obs.onNext("可以")
            obs.onNext("多個")
            obs.onError(self.err)
            obs.onCompleted()
            return Disposables.create()
        }
        
        
        ob.subscribe(onNext : { str in
            print(str)
        },onError: { err in
            print(err)
        }).disposed(by: disposeBag)
        

        
        //MARK:  single  只產生一個元素 或一個error
        print("********single********")
        let singleOB = Single<Any>.create { (single) -> Disposable in
            print("singleOB 是否共享")
            single(.success("Cooci"))
            single(.error(self.err))
           
            return Disposables.create()
        }
        
        
        
        singleOB.subscribe { (reslut) in
            print("訂閱:\(reslut)")
            }.disposed(by: disposeBag)
        
        //MARK:  Completable  只產生一個completed or 一個error  Completable 適用於那種你只關心任務是否完成，而不需要在意任務返回值的情況。它和 Observable<Void> 有點相似。
        print("********Completable********")
        let completableOB = Completable.create { (completable) -> Disposable in
            print("completableOB 是否共享")
            completable(.completed)
            completable(.error(self.err))
            return Disposables.create()
        }
        completableOB.subscribe { (reslut) in
            print("訂閱:\(reslut)")
            }.disposed(by: disposeBag)
         
        //MARK:  Maybe  只產生一個元素 or completed or 一個error
        print("********Maybe********")
        _ = Maybe<Any>.create { maybe -> Disposable in
            maybe(.error(self.err))
            maybe(.success("xxx"))
            maybe(.completed)
            return Disposables.create()
        }.subscribe(onSuccess: { str in
            print(str)
        }, onError: { eee in
            print(eee.localizedDescription)
        }, onCompleted: {
            print("completed")
        }).disposed(by: disposeBag)


        
    }
    
//MARK: - Subject 類型
    func Subject_Type()
    {
        
        //MARK:  PublishSubject 只有訂閱後的訊號
        print("********PublishSubject********")
        // 1:初始化序列
        let publishSub = PublishSubject<Int>() //初始化一個PublishSubject 裝著Int類型的序列
        // 2:發送響應序列
        publishSub.onNext(1)
        // 3:訂閱序列
        publishSub.subscribe { print("訂閱到了:",$0)}
            .disposed(by: self.disposeBag)
        // 再次發送響應
        publishSub.onNext(2)
        publishSub.onNext(3)
    
        
        //MARK:  BehaviorSubject 收到上一個訊號若無則發送初始值 有complete error事件 跟BehaviorSubject
        print("********BehaviorSubject********")
        let behaviorSub = BehaviorSubject<String>(value:"init")
        behaviorSub.onNext("1")
        behaviorSub.onNext("2")
        
        behaviorSub.subscribe(onNext:{
            print($0)
        }).disposed(by: self.disposeBag)
        behaviorSub.onCompleted()
        behaviorSub.onNext("3")
       
        
        //MARK:  ReplaySubject 可以收到往前n個事件 看buffer size
        print("********ReplaySubject********")
        let replaySub = ReplaySubject<Int>.create(bufferSize: 5)
        replaySub.onNext(1)
        replaySub.onNext(2)
        replaySub.onNext(3)
        replaySub.onNext(4)
        replaySub.subscribe{ print("訂閱到了:",$0)}
            .disposed(by: self.disposeBag)
        replaySub.onNext(7)
        
        
        //MARK:  AsyncSubject  只會收到完成前的最後一個事件
        print("********AsyncSubject********")
        let asynSub = AsyncSubject<Int>()
        asynSub.onNext(1)
        asynSub.onNext(2)
        asynSub.onCompleted()
        asynSub.onNext(3)
                
        asynSub.subscribe{ print("訂閱到了:",$0)}
        .disposed(by: self.disposeBag)
        
        //MARK:  BehaviorRelay 就是 BehaviorSubject 去掉終止事件 onError 或 onCompleted
        print("********BehaviorRelay********")
        let behaviorRelay = BehaviorRelay<Int>(value: 200)
        behaviorRelay.accept(500)
        behaviorRelay.subscribe(onNext: { (num) in
            print(num)
        }, onError: { (err) in
            print(err)
        }, onCompleted: {
            print("complete")
        }) {
            print("disposeable")
        }.disposed(by: self.disposeBag)
        
        behaviorRelay.accept(2000)
        behaviorRelay.accept(1000)
    }
    
//MARK: - Observable序列的創建方式
    func Observable序列的創建方式()
    {
        //MARK:  empty -- 空的
        print("********empty********")
        let empty = Observable<Int>.empty()
               
        _ = empty.subscribe(onNext : { num in print(num)
        }, onError:{ error in  print(error)
        }, onCompleted: { print("完成")
        },onDisposed: {print("釋放")})
        
        //MARK:  just -- 單個信號序列創建
        print("********just********")
        let arr = ["aa" , "bb"]
        Observable<[String]>.just(arr)
            .subscribe({ event in
                print(event)
            }).disposed(by: disposeBag)
        
        _ = Observable<[String]>.just(arr).subscribe(onNext : { number in
            print("訂閱：",number)
        },onError: { print("error:",$0)
        },onCompleted: {print("finish")
        },onDisposed: {print("dispose")})
        
        
        print("********of********")
        //MARK:  of - 多個元素 - 針對序列處理  可以兩個以上
        
        
        Observable<String>.of("cc","dd").subscribe { (event) in
            print(event)
        }.disposed(by: disposeBag)
    
        Observable<[String:Any]>.of(["ee":"ff"] , ["11":"22"])
            .subscribe { (event) in print(event)
            }.disposed(by: disposeBag)
        
        
        print("********from********")
        // MARK:  from - 將一個可選值轉換為 Observable：
        
        let optional: String? = "optional value"
        _ = Observable<String>.from(optional: optional)
            .subscribe { (event) in print(event)}
            .disposed(by: disposeBag)

        _ = Observable<[String]>.from(optional: ["opt1" , "opt2" ])
            .subscribe(onNext:{
                print($0)
            })
        
        print("********defer********")
        //MARK:  defer
        
        var isOdd = true
        _ = Observable<Int>.deferred({ () -> Observable<Int> in
            isOdd.toggle()
            if isOdd{
                return Observable.just(1)
            }
            else {
                return Observable.of(1,2,3)
            }
            }).subscribe({print($0)})
        
        
        print("********rang********")
        //MARK:  rang
         Observable.range(start: 2, count: 5)
            .subscribe { (event) in
                
                print(event)
        }.disposed(by: disposeBag)
        
        print("********generate********")
        //MARK:  generate

        // 數組遍歷
        let textArr = ["1","2","3","4","5","6","7","8","9","10"]
        Observable.generate(initialState: 0,// 初始值
            condition: { $0 < textArr.count}, // 條件1
            iterate: { $0 + 1 })  // 條件2 +2
            .subscribe(onNext: {
                print("遍歷arr:",textArr[$0])
            })
            .disposed(by: disposeBag)
        
        print("********timer********")
        //MARK:  timer  起始 間隔
//        Observable<Int>.timer(0, period: 1, scheduler: MainScheduler.instance).subscribe(onNext:{print($0)})
//        Observable<Int>.timer(0, scheduler: MainScheduler.instance).subscribe(onNext:{print($0)})
        
        print("********interval********")
        //MARK:  interval
        // 定時器  兩秒固定發送一次
//        Observable<Int>.interval(2, scheduler: MainScheduler.instance).subscribe { (event) in
//            print(event)
//        }
        
        print("********repeatElement********")
        //MARK:  repeatElement  ... // 无数次
//        Observable<Int>.repeatElement(5).subscribe({print($0)})
        
        print("********error********")
        //MARK:  error
        
        Observable<Int>.error(err).subscribe { (event) in
            print(event)
        }.disposed(by: disposeBag)
        
        print("********never********")
        //MARK:  never
        Observable<String>.never().subscribe({event in
            print(event)
            }).disposed(by: disposeBag)
        
        
        print("********create********")
        let ob = Observable<String>.create({ observ in
            observ.onNext("observable")
            observ.onCompleted()
            return Disposables.create()
        })
        
        ob.subscribe({print($0)}).disposed(by: disposeBag)
        ob.subscribe(onNext: {print($0)}).disposed(by: disposeBag)
    }
//MARK: - Observable序列的創建方式
    func 高階函數_組合操作符()
    {
        //MARK:  startWith
        print("*****startWith*****")
        
        Observable.of("1","2","3","4")
            .startWith("A")
            .startWith("B")
            .startWith("C","a","b")
            .subscribe(onNext: {print($0)})
            .disposed(by: disposeBag)
        //效果: CabBA1234
        
        //MARK:  merage
        print("*****merage*****")
        let subject1 = PublishSubject<String>()
        let subject2 = PublishSubject<String>()
        
        Observable.of(subject1,subject2).merge().subscribe(onNext:{
            print($0)
            }).disposed(by: disposeBag)
        
        subject1.onNext("sub1")
        subject2.onNext("sub2")
        subject1.onNext("sub11")
        
        //MARK:  zip
        print("*****zip*****")
        let stringSubject = PublishSubject<String>()
        let intSubject = PublishSubject<Int>()
        
        Observable.zip(stringSubject, intSubject){  stringElement, intElement in
             "\(stringElement) - \(intElement)"
        }.subscribe(onNext:{
            print($0 + " zip")
            }).disposed(by: disposeBag)
        
        stringSubject.onNext("C")
        stringSubject.onNext("o") // 到這裡存儲了 C o 但是不會響應除非;另一個響應
        
        intSubject.onNext(1) // 勾出一個
        intSubject.onNext(2) // 勾出另一個
        stringSubject.onNext("i") // 存一個
        intSubject.onNext(3) // 勾出一個
        // 說白了: 只有兩個序列同時有值的時候才會響應,否則存值
        
        //MARK:  combineLatest
        print("*****combineLatest*****")
        let stringSub = PublishSubject<String>()
        let intSub = PublishSubject<Int>()
        Observable.combineLatest(stringSub, intSub) { strElement, intElement in
                "\(strElement) + \(intElement)"
            }
            .subscribe(onNext: { print($0 + " combineLatest") })
            .disposed(by: disposeBag)

        stringSub.onNext("L") // 存一個 L
        stringSub.onNext("G") // 存了一個覆蓋 - 和zip不一樣
        intSub.onNext(1)      // 發現strOB也有G 響應 G 1
        intSub.onNext(2)      // 覆蓋1 -> 2 發現strOB 有值G 響應 G 2
        stringSub.onNext("Cooci") // 覆蓋G -> Cooci 發現intOB 有值2 響應 Cooci 2
        // combineLatest 比較zip 會覆蓋
        // 應用非常頻繁: 比如賬戶和密碼同時滿足->才能登陸. 不關係賬戶密碼怎麼變化的只要查看最後有值就可以 loginEnable

        //MARK:  switchLatest
        print("*****switchLatest*****")
        let switchLatestSub1 = BehaviorSubject(value: "L")
        let switchLatestSub2 = BehaviorSubject(value: "1")
        let switchLatestSub  = BehaviorSubject(value: switchLatestSub1)// 選擇了 switchLatestSub1 就不會監聽 switchLatestSub2

        switchLatestSub.asObservable()
            .switchLatest()
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)

        switchLatestSub1.onNext("G")
        switchLatestSub1.onNext("_")
        switchLatestSub2.onNext("2")
        switchLatestSub2.onNext("3") // 2-3都會不會監聽,但是默認保存由 2覆蓋1 3覆蓋2
        switchLatestSub.onNext(switchLatestSub2) // 切換到 switchLatestSub2
        switchLatestSub1.onNext("*")
        switchLatestSub1.onNext("Cooci") // 原理同上面 下面如果再次切換到 switchLatestSub1會打印出 Cooci
        switchLatestSub2.onNext("4")
        
    }
//MARK:  - 高階函數_映射操作符
    func 高階函數_映射操作符()
    {
        //MARK:  map
        print("*****map*****")
        let ob = Observable.of(1,2,3,4)
        ob.map { (num) -> Int in
            return num + 2
        }.subscribe(onNext:{
            print($0)
        }).disposed(by: disposeBag)
        
        //MARK:  flatMap
        print("*****flatMap*****")
        let disposeBag = DisposeBag()
        let first = BehaviorSubject(value: "👦🏻")
        let second = BehaviorSubject(value: "🅰️")
        let variable = Variable(first)

        variable.asObservable()
                .flatMap { $0 }
                .subscribe(onNext: { print($0) })
                .disposed(by: disposeBag)

        first.onNext("🐱")
        variable.value = second
        second.onNext("🅱️")
        first.onNext("🐶")
        
        
        //MARK:  scan
        print("*****scan*****")
        Observable.of(10, 100, 1000)
            .scan(2) { aggregateValue, newValue in
                aggregateValue + newValue // 10 + 2 , 100 + 10 + 2 , 1000 + 100 + 2
            }
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
    }
    
//MARK:  - 高階函數_過濾條件操作符
    func 高階函數_過濾條件操作符()
    {
        //MARK: filter -
        print("*****filter*****")
        let obs = Observable.of(1,2,3,4,5,6).filter { (num) -> Bool in
                return num % 2 == 0
            }
        obs.subscribe(onNext:{
            print($0)
            }).disposed(by: disposeBag)
        
        //MARK: distinctUntilChanged 去除重複的
        print("*****distinctUntilChanged*****")
        Observable.of("1", "2", "2", "2", "3", "3", "4")
            .distinctUntilChanged()
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        
        //MARK: elementAt 特定元素
        print("*****elementAt*****")
        Observable.of("1", "2", "3", "4", "5")
            .elementAt(3)
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        
        //MARK: single 指回傳符合的一個 若大於兩個則回傳錯誤
        print("*****single*****")
        Observable.of("Cooci", "Kody")
            .single()
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)

        Observable.of("Cooci", "Kody" )
            .single { $0 == "Kody" }
            .subscribe (onNext: { print($0) })
            .disposed(by: disposeBag)
        
        //MARK: take 取幾個
        print("*****take*****")
        Observable.of("1", "2","3", "4")
            .take(3)
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        
        //MARK: takeLast 取後面數來幾個
        print("*****takeLast*****")
        Observable.of("1", "2","3", "4")
            .takeLast(2)
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        
        //MARK: takeUntil
//        從源可觀察序列發出元素，直到參考可觀察序列發出元素
//        這個要重點,應用非常頻繁 比如我頁面銷毀了,就不能獲取值了(cell重用運用)

        print("*****takeUntil*****")
        let sourceSequence = PublishSubject<String>()
        let referenceSequence = PublishSubject<String>()

        sourceSequence
            .takeUntil(referenceSequence)
            .subscribe { print($0) }
            .disposed(by: disposeBag)
        
        sourceSequence.onNext("1")
        sourceSequence.onNext("2")
        sourceSequence.onNext("3")
        referenceSequence.onNext("a") // 條件一出來,下面就走不了
        sourceSequence.onNext("4")
        
        //MARK: skip
//        這個要重點,應用非常頻繁 不用解釋 textfiled 都會有默認序列產生
        print("*****skip*****")
        Observable.of(1, 2, 3, 4, 5, 6)
            .skip(2)
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)

        print("*****skipWhile*****")  // 成立就跳過
        Observable.of(1, 2, 3, 4, 5, 6)
            .skipWhile { $0 < 4 }
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)

        print("*****skipUntil*****")  //
        let sourceSeq = PublishSubject<String>()
        let referenceSeq = PublishSubject<String>()
        sourceSeq
            .skipUntil(referenceSeq)
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)

        // 沒有條件命令 下面走不了
        sourceSeq.onNext("1")
        sourceSeq.onNext("2")
        sourceSeq.onNext("3")
        referenceSeq.onNext("on") // 條件一出來,下面就可以走了
        sourceSeq.onNext("4")
    }
//MARK:  - 高階函數_集合控制操作符一
    func 高階函數_集合控制操作符一()
    {
        //MARK: toArray -
        print("*****toArray*****")
        
        PublishSubject.range(start: 1, count: 10)
        .toArray()
        .subscribe { print($0) }
        .disposed(by: disposeBag)
   
        //MARK: reduce -
        print("*****reduce*****")
        Observable.of(10, 100, 1000)
        .reduce(1, accumulator: +) // 1 + 10 + 100 + 1000 = 1111
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
        
        //MARK: concat -
        print("*****concat*****")
        let subject1 = BehaviorSubject(value: "Hank")
        let subject2 = BehaviorSubject(value: "1")

        let subjectsSubject = BehaviorSubject(value: subject1)
        
        subjectsSubject.asObservable()
            .concat()
            .subscribe { print($0) }
            .disposed(by: disposeBag)

        subject1.onNext("Cooci")
        subject1.onNext("Kody")

        subjectsSubject.onNext(subject2)

        subject2.onNext("打印不出來")
        subject2.onNext("2")

        subject1.onCompleted() // 必須要等subject1 完成了才能訂閱到! 用來控制順序 網絡數據的異步
        subject2.onNext("3")
        
    }
    
//MARK:  - 高階函數_集合控制操作符二
    func 高階函數_集合控制操作符二()
    {
        
        
        //MARK: catchErrorJustReturn - 失敗後即停止
        print("*****catchErrorJustReturn*****")
        let sequenceThatFails = PublishSubject<String>()

        sequenceThatFails
            .catchErrorJustReturn("Cooci")
            .subscribe { print($0) }
            .disposed(by: disposeBag)

        sequenceThatFails.onNext("Hank")
        sequenceThatFails.onNext("Kody") // 正常序列發送成功的
        //發送失敗的序列,一旦訂閱到位 返回我們之前設定的錯誤的預案
        sequenceThatFails.onError(err)
        sequenceThatFails.onNext("qqq")  // 不發送

        //MARK: catchError - 攔截失敗後替換另一組
        print("*****catchError*****")
        let recoverySequence = PublishSubject<String>()
        let sequenceThatFails22 = PublishSubject<String>()
        sequenceThatFails22
            .catchError {
                print("Error:", $0)
                return recoverySequence  // 獲取到了錯誤序列-我們在中間的閉包操作處理完畢,返回給用戶需要的序列(showAlert)
            }
            .subscribe { print($0) }
            .disposed(by: disposeBag)
        
        sequenceThatFails22.onNext("Hank")
        sequenceThatFails22.onNext("Kody") // 正常序列發送成功的
        sequenceThatFails22.onError(err) // 發送失敗的序列
        recoverySequence.onNext("CC") // 繼續發送
       
        //MARK: retry - 通過無限地重新訂閱可觀察序列來恢復重複的錯誤事件
        print("*****retry*****")
        var count = 1 // 外界變量控制流程
        let sequenceRetryErrors = Observable<String>.create { observer in
            observer.onNext("Hank")
            observer.onNext("Kody")
            observer.onNext("CC")
            
            if count == 1 {
                // 流程進來之後就會過度-這裡的條件可以作為出口,失敗的次數
                observer.onError(self.err)  // 接收到了錯誤序列,重試序列發生
                print("錯誤序列來了")
                count += 1
            }
            
            observer.onNext("Lina")
            observer.onNext("小雁子")
            observer.onNext("婷婷")
            observer.onCompleted()
            
            return Disposables.create()
        }

        sequenceRetryErrors
            .retry()
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        
        //MARK: retry(_:) - 直到重試次數達到max為止 遇到onError則進行下一回合
        print("*****retry(_:)*****")
        var conunt2 = 1
        let sequenceThatErrors2 = Observable<String>.create { observer in
            observer.onNext("1")
            observer.onNext("2")
            observer.onNext("3")
            if conunt2 < 3 {
                observer.onError(self.err)
                print("錯誤序列")
                conunt2 += 1
            }
            observer.onNext("4")
            observer.onNext("5")
            observer.onCompleted()
            return Disposables.create()
        }
        sequenceThatErrors2.retry(5).subscribe({
            print($0)
            }).disposed(by: disposeBag)
        

        //MARK: RxSwift.Resources.total : 提供所有Rx資源分配的計數，這對於在開發期間檢測洩漏非常有用
        print("*****RxSwift.Resources.total*****")
        
        print(RxSwift.Resources.total)
        let subject = BehaviorSubject(value: "Cooci")
        let subscription1 = subject.subscribe(onNext: { print($0) })
        print(RxSwift.Resources.total)
        let subscription2 = subject.subscribe(onNext: { print($0) })
        print(RxSwift.Resources.total)
        subscription1.dispose()
        print(RxSwift.Resources.total)
        subscription2.dispose()
        print(RxSwift.Resources.total)
        
        //MARK: multicast   注意 publish() 被訂閱後不會發出元素，直到 connect 操作符被應用為止
        print("*****multicast*****")
        let netOB = Observable<Any>.create { (observer) -> Disposable in
//                sleep(2)// 模擬網絡延遲
                print("我開始請求網絡了")
                observer.onNext("請求到的網絡數據")
                observer.onNext("請求到的本地")
                observer.onCompleted()
                return Disposables.create {
                    print("銷毀回調了")
                }
            }.publish()
        netOB.subscribe(onNext: { (anything) in
                print("訂閱1:",anything)
            })
            .disposed(by: disposeBag)
        netOB.subscribe(onNext: { (anything) in
                print("訂閱2:",anything)
            })
            .disposed(by: disposeBag)
        _ = netOB.connect()
        
        //MARK: replay
        print("*****replay*****")
//        let intSequence = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
//            .replay(5)
//        _ = intSequence
//            .subscribe(onNext: { print("Subscription 1:, Event: \($0)") })
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            _ = intSequence.connect()
//        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
//          _ = intSequence
//              .subscribe(onNext: { print("Subscription 2:, Event: \($0)") })
//        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
//          _ = intSequence
//              .subscribe(onNext: { print("Subscription 3:, Event: \($0)") })
//        }

    }
    
}

