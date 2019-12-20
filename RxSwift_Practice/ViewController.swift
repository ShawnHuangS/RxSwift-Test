//
//  ViewController.swift
//  RxSwift_Practice
//
//  Created by ShawnHuang on 2019/12/17.
//  Copyright © 2019 ShawnHuang. All rights reserved.
//

import UIKit
import RxSwift
class ViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    override func viewDidLoad() {
        
        super.viewDidLoad()

//        Observable序列的創建方式()
//        高階函數_組合操作符()
//        高階函數_映射操作符()
//        高階函數_過濾條件操作符()
        高階函數_集合控制操作符()

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
        let err = NSError(domain: "errorDomain", code: 123, userInfo: ["test":"error"])
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
//        let boy  = LGPlayer(score: 100)
//        let girl = LGPlayer(score: 90)
//        let player = BehaviorSubject(value: boy)
//
//        player.asObservable()
//            .flatMap { $0.score.asObservable() } // 本身score就是序列 模型就是序列中的序列
//            .subscribe(onNext: { print($0) })
//            .disposed(by: disposeBag)
//        boy.score.onNext(60)
//        player.onNext(girl)
//        boy.score.onNext(50)
//        boy.score.onNext(40)//  如果切換到 flatMapLatest 就不會打印
//        girl.score.onNext(10)
//        girl.score.onNext(0)
        
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
    
    func 高階函數_集合控制操作符()
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
}
testtest
