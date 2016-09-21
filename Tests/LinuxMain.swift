import XCTest
@testable import RxSwiftTests

extension SubjectConcurrencyTest {
    static var allTests: [(String, (SubjectConcurrencyTest) -> () throws -> Void)] {
        return [
            ("testSubjectIsSynchronized", testSubjectIsSynchronized),
            ("testSubjectIsReentrantForNextAndComplete", testSubjectIsReentrantForNextAndComplete),
            ("testSubjectIsReentrantForNextAndError", testSubjectIsReentrantForNextAndError),
        ]
    }
}

extension ObservableBlockingTest {
    static var allTests: [(String, (ObservableBlockingTest) -> () throws -> Void)] {
        return [
            ("testToArray_empty", testToArray_empty),
            ("testToArray_return", testToArray_return),
            ("testToArray_fail", testToArray_fail),
            ("testToArray_someData", testToArray_someData),
            ("testToArray_withRealScheduler", testToArray_withRealScheduler),
            ("testToArray_independent", testToArray_independent),
            ("testToArray_timeout", testToArray_timeout),
            ("testFirst_empty", testFirst_empty),
            ("testFirst_return", testFirst_return),
            ("testFirst_fail", testFirst_fail),
            ("testFirst_someData", testFirst_someData),
            ("testFirst_withRealScheduler", testFirst_withRealScheduler),
            ("testFirst_independent", testFirst_independent),
            ("testFirst_timeout", testFirst_timeout),
            ("testLast_empty", testLast_empty),
            ("testLast_return", testLast_return),
            ("testLast_fail", testLast_fail),
            ("testLast_someData", testLast_someData),
            ("testLast_withRealScheduler", testLast_withRealScheduler),
            ("testLast_independent", testLast_independent),
            ("testLast_timeout", testLast_timeout),
            ("testSingle_empty", testSingle_empty),
            ("testSingle_return", testSingle_return),
            ("testSingle_two", testSingle_two),
            ("testSingle_someData", testSingle_someData),
            ("testSingle_fail", testSingle_fail),
            ("testSingle_withRealScheduler", testSingle_withRealScheduler),
            ("testSingle_predicate_empty", testSingle_predicate_empty),
            ("testSingle_predicate_return", testSingle_predicate_return),
            ("testSingle_predicate_someData_one_match", testSingle_predicate_someData_one_match),
            ("testSingle_predicate_someData_two_match", testSingle_predicate_someData_two_match),
            ("testSingle_predicate_none", testSingle_predicate_none),
            ("testSingle_predicate_throws", testSingle_predicate_throws),
            ("testSingle_predicate_fail", testSingle_predicate_fail),
            ("testSingle_predicate_withRealScheduler", testSingle_predicate_withRealScheduler),
            ("testSingle_independent", testSingle_independent),
            ("testSingle_timeout", testSingle_timeout),
            ("testSinglePredicate_timeout", testSinglePredicate_timeout),
        ]
    }
}

extension BehaviorSubjectTest {
    static var allTests: [(String, (BehaviorSubjectTest) -> () throws -> Void)] {
        return [
            ("test_Infinite", test_Infinite),
            ("test_Finite", test_Finite),
            ("test_Error", test_Error),
            ("test_Canceled", test_Canceled),
            ("test_hasObserversNoObservers", test_hasObserversNoObservers),
            ("test_hasObserversOneObserver", test_hasObserversOneObserver),
            ("test_hasObserversManyObserver", test_hasObserversManyObserver),
        ]
    }
}

extension DisposableTest {
    static var allTests: [(String, (DisposableTest) -> () throws -> Void)] {
        return [
            ("testActionDisposable", testActionDisposable),
            ("testHotObservable_Disposing", testHotObservable_Disposing),
            ("testCompositeDisposable_TestNormal", testCompositeDisposable_TestNormal),
            ("testCompositeDisposable_TestInitWithNumberOfDisposables", testCompositeDisposable_TestInitWithNumberOfDisposables),
            ("testCompositeDisposable_TestRemoving", testCompositeDisposable_TestRemoving),
            ("testDisposables_TestCreateWithNumberOfDisposables", testDisposables_TestCreateWithNumberOfDisposables),
            ("testRefCountDisposable_RefCounting", testRefCountDisposable_RefCounting),
            ("testRefCountDisposable_PrimaryDisposesFirst", testRefCountDisposable_PrimaryDisposesFirst),
        ]
    }
}

extension ObservableConcurrencyTest {
    static var allTests: [(String, (ObservableConcurrencyTest) -> () throws -> Void)] {
        return [
            ("testObserveOnDispatchQueue_DoesPerformWorkOnQueue", testObserveOnDispatchQueue_DoesPerformWorkOnQueue),
            ("testObserveOnDispatchQueue_DeadlockErrorImmediatelly", testObserveOnDispatchQueue_DeadlockErrorImmediatelly),
            ("testObserveOnDispatchQueue_DeadlockEmpty", testObserveOnDispatchQueue_DeadlockEmpty),
            ("testObserveOnDispatchQueue_Never", testObserveOnDispatchQueue_Never),
            ("testObserveOnDispatchQueue_Simple", testObserveOnDispatchQueue_Simple),
            ("testObserveOnDispatchQueue_Empty", testObserveOnDispatchQueue_Empty),
            ("testObserveOnDispatchQueue_Error", testObserveOnDispatchQueue_Error),
            ("testObserveOnDispatchQueue_Dispose", testObserveOnDispatchQueue_Dispose),
            ("testSubscribeOn_SchedulerSleep", testSubscribeOn_SchedulerSleep),
            ("testSubscribeOn_SchedulerCompleted", testSubscribeOn_SchedulerCompleted),
            ("testSubscribeOn_SchedulerError", testSubscribeOn_SchedulerError),
            ("testSubscribeOn_SchedulerDispose", testSubscribeOn_SchedulerDispose),
        ]
    }
}

extension ObservableDebugTest {
    static var allTests: [(String, (ObservableDebugTest) -> () throws -> Void)] {
        return [
            ("testDebug_Completed", testDebug_Completed),
            ("testDebug_Error", testDebug_Error),
        ]
    }
}

extension AnonymousObservableTests {
    static var allTests: [(String, (AnonymousObservableTests) -> () throws -> Void)] {
        return [
            ("testAnonymousObservable_detachesOnDispose", testAnonymousObservable_detachesOnDispose),
            ("testAnonymousObservable_detachesOnComplete", testAnonymousObservable_detachesOnComplete),
            ("testAnonymousObservable_detachesOnError", testAnonymousObservable_detachesOnError),
        ]
    }
}

extension ObservableCreationTests {
    static var allTests: [(String, (ObservableCreationTests) -> () throws -> Void)] {
        return [
            ("testJust_Immediate", testJust_Immediate),
            ("testJust_Basic", testJust_Basic),
            ("testJust_Disposed", testJust_Disposed),
            ("testJust_DisposeAfterNext", testJust_DisposeAfterNext),
            ("testJust_DefaultScheduler", testJust_DefaultScheduler),
            ("testFromArray_complete_immediate", testFromArray_complete_immediate),
            ("testFromArray_complete", testFromArray_complete),
            ("testFromArray_dispose", testFromArray_dispose),
            ("testSequenceOf_complete_immediate", testSequenceOf_complete_immediate),
            ("testSequenceOf_complete", testSequenceOf_complete),
            ("testSequenceOf_dispose", testSequenceOf_dispose),
            ("testFromAnySequence_basic_immediate", testFromAnySequence_basic_immediate),
            ("testToObservableAnySequence_basic_testScheduler", testToObservableAnySequence_basic_testScheduler),
            ("testGenerate_Finite", testGenerate_Finite),
            ("testGenerate_ThrowCondition", testGenerate_ThrowCondition),
            ("testGenerate_ThrowIterate", testGenerate_ThrowIterate),
            ("testGenerate_Dispose", testGenerate_Dispose),
            ("testGenerate_take", testGenerate_take),
            ("testRange_Boundaries", testRange_Boundaries),
            ("testRange_Dispose", testRange_Dispose),
            ("testRepeat_Element", testRepeat_Element),
            ("testUsing_Complete", testUsing_Complete),
            ("testUsing_Error", testUsing_Error),
            ("testUsing_Dispose", testUsing_Dispose),
            ("testUsing_ThrowResourceSelector", testUsing_ThrowResourceSelector),
            ("testUsing_ThrowResourceUsage", testUsing_ThrowResourceUsage),
        ]
    }
}

extension MainSchedulerTest {
    static var allTests: [(String, (MainSchedulerTest) -> () throws -> Void)] {
        return [
            ("testMainScheduler_basicScenario", testMainScheduler_basicScenario),
            ("testMainScheduler_disposing1", testMainScheduler_disposing1),
            ("testMainScheduler_disposing2", testMainScheduler_disposing2),
        ]
    }
}

extension VirtualSchedulerTest {
    static var allTests: [(String, (VirtualSchedulerTest) -> () throws -> Void)] {
        return [
            ("testVirtualScheduler_initialClock", testVirtualScheduler_initialClock),
            ("testVirtualScheduler_start", testVirtualScheduler_start),
            ("testVirtualScheduler_disposeStart", testVirtualScheduler_disposeStart),
            ("testVirtualScheduler_advanceToAfter", testVirtualScheduler_advanceToAfter),
            ("testVirtualScheduler_advanceToBefore", testVirtualScheduler_advanceToBefore),
            ("testVirtualScheduler_disposeAdvanceTo", testVirtualScheduler_disposeAdvanceTo),
            ("testVirtualScheduler_stop", testVirtualScheduler_stop),
            ("testVirtualScheduler_sleep", testVirtualScheduler_sleep),
            ("testVirtualScheduler_stress", testVirtualScheduler_stress),
        ]
    }
}

extension AssumptionsTest {
    static var allTests: [(String, (AssumptionsTest) -> () throws -> Void)] {
        return [
            ("testAssumptionInCodeIsThatArraysAreStructs", testAssumptionInCodeIsThatArraysAreStructs),
            ("testFunctionCallRetainsArguments", testFunctionCallRetainsArguments),
            ("testFunctionReturnValueOverload", testFunctionReturnValueOverload),
            ("testArrayMutation", testArrayMutation),
            ("testResourceLeaksDetectionIsTurnedOn", testResourceLeaksDetectionIsTurnedOn),
        ]
    }
}

extension QueueTest {
    static var allTests: [(String, (QueueTest) -> () throws -> Void)] {
        return [
            ("test", test),
            ("testComplexity", testComplexity),
        ]
    }
}

extension CurrentThreadSchedulerTest {
    static var allTests: [(String, (CurrentThreadSchedulerTest) -> () throws -> Void)] {
        return [
            ("testCurrentThreadScheduler_scheduleRequired", testCurrentThreadScheduler_scheduleRequired),
            ("testCurrentThreadScheduler_basicScenario", testCurrentThreadScheduler_basicScenario),
            ("testCurrentThreadScheduler_disposing1", testCurrentThreadScheduler_disposing1),
            ("testCurrentThreadScheduler_disposing2", testCurrentThreadScheduler_disposing2),
        ]
    }
}

extension HistoricalSchedulerTest {
    static var allTests: [(String, (HistoricalSchedulerTest) -> () throws -> Void)] {
        return [
            ("testHistoricalScheduler_initialClock", testHistoricalScheduler_initialClock),
            ("testHistoricalScheduler_start", testHistoricalScheduler_start),
            ("testHistoricalScheduler_disposeStart", testHistoricalScheduler_disposeStart),
            ("testHistoricalScheduler_advanceToAfter", testHistoricalScheduler_advanceToAfter),
            ("testHistoricalScheduler_advanceToBefore", testHistoricalScheduler_advanceToBefore),
            ("testHistoricalScheduler_disposeAdvanceTo", testHistoricalScheduler_disposeAdvanceTo),
            ("testHistoricalScheduler_stop", testHistoricalScheduler_stop),
            ("testHistoricalScheduler_sleep", testHistoricalScheduler_sleep),
        ]
    }
}

extension ObservableMultipleTest {
    static var allTests: [(String, (ObservableMultipleTest) -> () throws -> Void)] {
        return [
            ("testCatch_ErrorSpecific_Caught", testCatch_ErrorSpecific_Caught),
            ("testCatch_HandlerThrows", testCatch_HandlerThrows),
            ("testCatchSequenceOf_IEofIO", testCatchSequenceOf_IEofIO),
            ("testCatchAnySequence_NoErrors", testCatchAnySequence_NoErrors),
            ("testCatchAnySequence_Never", testCatchAnySequence_Never),
            ("testCatchAnySequence_Empty", testCatchAnySequence_Empty),
            ("testCatchSequenceOf_Error", testCatchSequenceOf_Error),
            ("testCatchSequenceOf_ErrorNever", testCatchSequenceOf_ErrorNever),
            ("testCatchSequenceOf_ErrorError", testCatchSequenceOf_ErrorError),
            ("testCatchSequenceOf_Multiple", testCatchSequenceOf_Multiple),
            ("testSwitch_Data", testSwitch_Data),
            ("testSwitch_InnerThrows", testSwitch_InnerThrows),
            ("testSwitch_OuterThrows", testSwitch_OuterThrows),
            ("testFlatMapLatest_Data", testFlatMapLatest_Data),
            ("testFlatMapLatest_InnerThrows", testFlatMapLatest_InnerThrows),
            ("testFlatMapLatest_OuterThrows", testFlatMapLatest_OuterThrows),
            ("testFlatMapLatest_SelectorThrows", testFlatMapLatest_SelectorThrows),
            ("testConcat_DefaultScheduler", testConcat_DefaultScheduler),
            ("testConcat_IEofIO", testConcat_IEofIO),
            ("testConcat_EmptyEmpty", testConcat_EmptyEmpty),
            ("testConcat_EmptyNever", testConcat_EmptyNever),
            ("testConcat_NeverNever", testConcat_NeverNever),
            ("testConcat_EmptyThrow", testConcat_EmptyThrow),
            ("testConcat_ThrowEmpty", testConcat_ThrowEmpty),
            ("testConcat_ThrowThrow", testConcat_ThrowThrow),
            ("testConcat_ReturnEmpty", testConcat_ReturnEmpty),
            ("testConcat_EmptyReturn", testConcat_EmptyReturn),
            ("testConcat_ReturnNever", testConcat_ReturnNever),
            ("testConcat_NeverReturn", testConcat_NeverReturn),
            ("testConcat_ReturnReturn", testConcat_ReturnReturn),
            ("testConcat_ThrowReturn", testConcat_ThrowReturn),
            ("testConcat_ReturnThrow", testConcat_ReturnThrow),
            ("testConcat_SomeDataSomeData", testConcat_SomeDataSomeData),
            ("testConcat_EnumerableTiming", testConcat_EnumerableTiming),
            ("testMerge_DeadlockSimple", testMerge_DeadlockSimple),
            ("testMerge_DeadlockErrorAfterN", testMerge_DeadlockErrorAfterN),
            ("testMerge_DeadlockErrorImmediatelly", testMerge_DeadlockErrorImmediatelly),
            ("testMerge_DeadlockEmpty", testMerge_DeadlockEmpty),
            ("testMerge_DeadlockFirstEmpty", testMerge_DeadlockFirstEmpty),
            ("testMergeConcurrent_DeadlockSimple", testMergeConcurrent_DeadlockSimple),
            ("testMergeConcurrent_DeadlockErrorAfterN", testMergeConcurrent_DeadlockErrorAfterN),
            ("testMergeConcurrent_DeadlockErrorImmediatelly", testMergeConcurrent_DeadlockErrorImmediatelly),
            ("testMergeConcurrent_DeadlockEmpty", testMergeConcurrent_DeadlockEmpty),
            ("testMergeConcurrent_DeadlockFirstEmpty", testMergeConcurrent_DeadlockFirstEmpty),
            ("testMerge_ObservableOfObservable_Data", testMerge_ObservableOfObservable_Data),
            ("testMerge_ObservableOfObservable_Data_NotOverlapped", testMerge_ObservableOfObservable_Data_NotOverlapped),
            ("testMerge_ObservableOfObservable_InnerThrows", testMerge_ObservableOfObservable_InnerThrows),
            ("testMerge_ObservableOfObservable_OuterThrows", testMerge_ObservableOfObservable_OuterThrows),
            ("testMerge_MergeConcat_Basic", testMerge_MergeConcat_Basic),
            ("testMerge_MergeConcat_BasicLong", testMerge_MergeConcat_BasicLong),
            ("testMerge_MergeConcat_BasicWide", testMerge_MergeConcat_BasicWide),
            ("testMerge_MergeConcat_BasicLate", testMerge_MergeConcat_BasicLate),
            ("testMerge_MergeConcat_Disposed", testMerge_MergeConcat_Disposed),
            ("testMerge_MergeConcat_OuterError", testMerge_MergeConcat_OuterError),
            ("testMerge_MergeConcat_InnerError", testMerge_MergeConcat_InnerError),
            ("testCombineLatest_DeadlockErrorAfterN", testCombineLatest_DeadlockErrorAfterN),
            ("testCombineLatest_DeadlockErrorImmediatelly", testCombineLatest_DeadlockErrorImmediatelly),
            ("testReplay_DeadlockEmpty", testReplay_DeadlockEmpty),
            ("testTakeUntil_Preempt_SomeData_Next", testTakeUntil_Preempt_SomeData_Next),
            ("testTakeUntil_Preempt_SomeData_Error", testTakeUntil_Preempt_SomeData_Error),
            ("testTakeUntil_NoPreempt_SomeData_Empty", testTakeUntil_NoPreempt_SomeData_Empty),
            ("testTakeUntil_NoPreempt_SomeData_Never", testTakeUntil_NoPreempt_SomeData_Never),
            ("testTakeUntil_Preempt_Never_Next", testTakeUntil_Preempt_Never_Next),
            ("testTakeUntil_Preempt_Never_Error", testTakeUntil_Preempt_Never_Error),
            ("testTakeUntil_NoPreempt_Never_Empty", testTakeUntil_NoPreempt_Never_Empty),
            ("testTakeUntil_NoPreempt_Never_Never", testTakeUntil_NoPreempt_Never_Never),
            ("testTakeUntil_Preempt_BeforeFirstProduced", testTakeUntil_Preempt_BeforeFirstProduced),
            ("testTakeUntil_Preempt_BeforeFirstProduced_RemainSilentAndProperDisposed", testTakeUntil_Preempt_BeforeFirstProduced_RemainSilentAndProperDisposed),
            ("testTakeUntil_NoPreempt_AfterLastProduced_ProperDisposedSigna", testTakeUntil_NoPreempt_AfterLastProduced_ProperDisposedSigna),
            ("testTakeUntil_Error_Some", testTakeUntil_Error_Some),
            ("testAmb_Never2", testAmb_Never2),
            ("testAmb_Never3", testAmb_Never3),
            ("testAmb_Never_Empty", testAmb_Never_Empty),
            ("testAmb_RegularShouldDisposeLoser", testAmb_RegularShouldDisposeLoser),
            ("testAmb_WinnerThrows", testAmb_WinnerThrows),
            ("testAmb_LoserThrows", testAmb_LoserThrows),
            ("testAmb_ThrowsBeforeElectionLeft", testAmb_ThrowsBeforeElectionLeft),
            ("testAmb_ThrowsBeforeElectionRight", testAmb_ThrowsBeforeElectionRight),
            ("testCombineLatest_NeverN", testCombineLatest_NeverN),
            ("testCombineLatest_NeverEmptyN", testCombineLatest_NeverEmptyN),
            ("testCombineLatest_EmptyNeverN", testCombineLatest_EmptyNeverN),
            ("testCombineLatest_EmptyReturnN", testCombineLatest_EmptyReturnN),
            ("testCombineLatest_ReturnReturnN", testCombineLatest_ReturnReturnN),
            ("testCombineLatest_EmptyErrorN", testCombineLatest_EmptyErrorN),
            ("testCombineLatest_ReturnErrorN", testCombineLatest_ReturnErrorN),
            ("testCombineLatest_ErrorErrorN", testCombineLatest_ErrorErrorN),
            ("testCombineLatest_NeverErrorN", testCombineLatest_NeverErrorN),
            ("testCombineLatest_SomeErrorN", testCombineLatest_SomeErrorN),
            ("testCombineLatest_ErrorAfterCompletedN", testCombineLatest_ErrorAfterCompletedN),
            ("testCombineLatest_InterleavedWithTailN", testCombineLatest_InterleavedWithTailN),
            ("testCombineLatest_ConsecutiveN", testCombineLatest_ConsecutiveN),
            ("testCombineLatest_ConsecutiveNWithErrorLeft", testCombineLatest_ConsecutiveNWithErrorLeft),
            ("testCombineLatest_ConsecutiveNWithErrorRight", testCombineLatest_ConsecutiveNWithErrorRight),
            ("testCombineLatest_SelectorThrowsN", testCombineLatest_SelectorThrowsN),
            ("testCombineLatest_willNeverBeAbleToCombineN", testCombineLatest_willNeverBeAbleToCombineN),
            ("testCombineLatest_typicalN", testCombineLatest_typicalN),
            ("testCombineLatest_NAry_symmetric", testCombineLatest_NAry_symmetric),
            ("testCombineLatest_NAry_asymmetric", testCombineLatest_NAry_asymmetric),
            ("testZip_NAry_symmetric", testZip_NAry_symmetric),
            ("testZip_NAry_asymmetric", testZip_NAry_asymmetric),
            ("testZip_NAry_error", testZip_NAry_error),
            ("testZip_NAry_atLeastOneErrors4", testZip_NAry_atLeastOneErrors4),
            ("testSkipUntil_SomeData_Next", testSkipUntil_SomeData_Next),
            ("testSkipUntil_SomeData_Error", testSkipUntil_SomeData_Error),
            ("testSkipUntil_Error_SomeData", testSkipUntil_Error_SomeData),
            ("testSkipUntil_SomeData_Empty", testSkipUntil_SomeData_Empty),
            ("testSkipUntil_Never_Next", testSkipUntil_Never_Next),
            ("testSkipUntil_Never_Error1", testSkipUntil_Never_Error1),
            ("testSkipUntil_SomeData_Error2", testSkipUntil_SomeData_Error2),
            ("testSkipUntil_SomeData_Never", testSkipUntil_SomeData_Never),
            ("testSkipUntil_Never_Empty", testSkipUntil_Never_Empty),
            ("testSkipUntil_Never_Never", testSkipUntil_Never_Never),
            ("testSkipUntil_HasCompletedCausesDisposal", testSkipUntil_HasCompletedCausesDisposal),
            ("testWithLatestFrom_Simple1", testWithLatestFrom_Simple1),
            ("testWithLatestFrom_TwoObservablesWithImmediateValues", testWithLatestFrom_TwoObservablesWithImmediateValues),
            ("testWithLatestFrom_Simple2", testWithLatestFrom_Simple2),
            ("testWithLatestFrom_Simple3", testWithLatestFrom_Simple3),
            ("testWithLatestFrom_Error1", testWithLatestFrom_Error1),
            ("testWithLatestFrom_Error2", testWithLatestFrom_Error2),
            ("testWithLatestFrom_Error3", testWithLatestFrom_Error3),
            ("testWithLatestFrom_MakeSureDefaultOverloadTakesSecondSequenceValues", testWithLatestFrom_MakeSureDefaultOverloadTakesSecondSequenceValues),
        ]
    }
}

extension BagTest {
    static var allTests: [(String, (BagTest) -> () throws -> Void)] {
        return [
            ("testBag_deletionsFromStart", testBag_deletionsFromStart),
            ("testBag_deletionsFromEnd", testBag_deletionsFromEnd),
            ("testBag_immutableForeach", testBag_immutableForeach),
            ("testBag_removeAll", testBag_removeAll),
            ("testBag_complexityTestFromFront", testBag_complexityTestFromFront),
            ("testBag_complexityTestFromEnd", testBag_complexityTestFromEnd),
        ]
    }
}

extension ObservableSingleTest {
    static var allTests: [(String, (ObservableSingleTest) -> () throws -> Void)] {
        return [
            ("testAsObservable_asObservable", testAsObservable_asObservable),
            ("testAsObservable_hides", testAsObservable_hides),
            ("testAsObservable_never", testAsObservable_never),
            ("testDistinctUntilChanged_allChanges", testDistinctUntilChanged_allChanges),
            ("testDistinctUntilChanged_someChanges", testDistinctUntilChanged_someChanges),
            ("testDistinctUntilChanged_allEqual", testDistinctUntilChanged_allEqual),
            ("testDistinctUntilChanged_allDifferent", testDistinctUntilChanged_allDifferent),
            ("testDistinctUntilChanged_keySelector_Div2", testDistinctUntilChanged_keySelector_Div2),
            ("testDistinctUntilChanged_keySelectorThrows", testDistinctUntilChanged_keySelectorThrows),
            ("testDistinctUntilChanged_comparerThrows", testDistinctUntilChanged_comparerThrows),
            ("testRetry_Basic", testRetry_Basic),
            ("testRetry_Infinite", testRetry_Infinite),
            ("testRetry_Observable_Error", testRetry_Observable_Error),
            ("testRetryCount_Basic", testRetryCount_Basic),
            ("testRetryCount_Dispose", testRetryCount_Dispose),
            ("testRetryCount_Infinite", testRetryCount_Infinite),
            ("testRetryCount_Completed", testRetryCount_Completed),
            ("testRetry_tailRecursiveOptimizationsTest", testRetry_tailRecursiveOptimizationsTest),
            ("testRetryWhen_Never", testRetryWhen_Never),
            ("testRetryWhen_ObservableNever", testRetryWhen_ObservableNever),
            ("testRetryWhen_ObservableNeverComplete", testRetryWhen_ObservableNeverComplete),
            ("testRetryWhen_ObservableEmpty", testRetryWhen_ObservableEmpty),
            ("testRetryWhen_ObservableNextError", testRetryWhen_ObservableNextError),
            ("testRetryWhen_ObservableComplete", testRetryWhen_ObservableComplete),
            ("testRetryWhen_ObservableNextComplete", testRetryWhen_ObservableNextComplete),
            ("testRetryWhen_ObservableInfinite", testRetryWhen_ObservableInfinite),
            ("testRetryWhen_Incremental_BackOff", testRetryWhen_Incremental_BackOff),
            ("testRetryWhen_IgnoresDifferentErrorTypes", testRetryWhen_IgnoresDifferentErrorTypes),
            ("testRetryWhen_tailRecursiveOptimizationsTest", testRetryWhen_tailRecursiveOptimizationsTest),
            ("testScan_Seed_Never", testScan_Seed_Never),
            ("testScan_Seed_Empty", testScan_Seed_Empty),
            ("testScan_Seed_Return", testScan_Seed_Return),
            ("testScan_Seed_Throw", testScan_Seed_Throw),
            ("testScan_Seed_SomeData", testScan_Seed_SomeData),
            ("testScan_Seed_AccumulatorThrows", testScan_Seed_AccumulatorThrows),
        ]
    }
}

extension ObserverTests {
    static var allTests: [(String, (ObserverTests) -> () throws -> Void)] {
        return [
            ("testConvenienceOn_Next", testConvenienceOn_Next),
            ("testConvenienceOn_Error", testConvenienceOn_Error),
            ("testConvenienceOn_Complete", testConvenienceOn_Complete),
        ]
    }
}

extension PublishSubjectTest {
    static var allTests: [(String, (PublishSubjectTest) -> () throws -> Void)] {
        return [
            ("test_hasObserversNoObservers", test_hasObserversNoObservers),
            ("test_hasObserversOneObserver", test_hasObserversOneObserver),
            ("test_hasObserversManyObserver", test_hasObserversManyObserver),
        ]
    }
}

extension ReplaySubjectTest {
    static var allTests: [(String, (ReplaySubjectTest) -> () throws -> Void)] {
        return [
            ("test_hasObserversNoObservers", test_hasObserversNoObservers),
            ("test_hasObserversOneObserver", test_hasObserversOneObserver),
            ("test_hasObserversManyObserver", test_hasObserversManyObserver),
        ]
    }
}

extension ObservableBindingTest {
    static var allTests: [(String, (ObservableBindingTest) -> () throws -> Void)] {
        return [
            ("testMulticast_Cold_Completed", testMulticast_Cold_Completed),
            ("testMulticast_Cold_Error", testMulticast_Cold_Error),
            ("testMulticast_Cold_Dispose", testMulticast_Cold_Dispose),
            ("testMulticast_Cold_Zip", testMulticast_Cold_Zip),
            ("testMulticast_SubjectSelectorThrows", testMulticast_SubjectSelectorThrows),
            ("testMulticast_SelectorThrows", testMulticast_SelectorThrows),
            ("testRefCount_DeadlockSimple", testRefCount_DeadlockSimple),
            ("testRefCount_DeadlockErrorAfterN", testRefCount_DeadlockErrorAfterN),
            ("testRefCount_DeadlockErrorImmediatelly", testRefCount_DeadlockErrorImmediatelly),
            ("testRefCount_DeadlockEmpty", testRefCount_DeadlockEmpty),
            ("testRefCount_ConnectsOnFirst", testRefCount_ConnectsOnFirst),
            ("testRefCount_NotConnected", testRefCount_NotConnected),
            ("testRefCount_Error", testRefCount_Error),
            ("testRefCount_Publish", testRefCount_Publish),
            ("testReplayCount_Basic", testReplayCount_Basic),
            ("testReplayCount_Error", testReplayCount_Error),
            ("testReplayCount_Complete", testReplayCount_Complete),
            ("testReplayCount_Dispose", testReplayCount_Dispose),
            ("testReplayOneCount_Basic", testReplayOneCount_Basic),
            ("testReplayOneCount_Error", testReplayOneCount_Error),
            ("testReplayOneCount_Complete", testReplayOneCount_Complete),
            ("testReplayOneCount_Dispose", testReplayOneCount_Dispose),
            ("testReplayAll_Basic", testReplayAll_Basic),
            ("testReplayAll_Error", testReplayAll_Error),
            ("testReplayAll_Complete", testReplayAll_Complete),
            ("testReplayAll_Dispose", testReplayAll_Dispose),
            ("testShareReplay_DeadlockImmediatelly", testShareReplay_DeadlockImmediatelly),
            ("testShareReplay_DeadlockEmpty", testShareReplay_DeadlockEmpty),
            ("testShareReplay_DeadlockError", testShareReplay_DeadlockError),
            ("testShareReplay1_DeadlockErrorAfterN", testShareReplay1_DeadlockErrorAfterN),
            ("testShareReplay1_Basic", testShareReplay1_Basic),
            ("testShareReplay1_Error", testShareReplay1_Error),
            ("testShareReplay1_Completed", testShareReplay1_Completed),
            ("testShareReplay1_Canceled", testShareReplay1_Canceled),
            ("testShareReplayLatestWhileConnected_DeadlockImmediatelly", testShareReplayLatestWhileConnected_DeadlockImmediatelly),
            ("testShareReplayLatestWhileConnected_DeadlockEmpty", testShareReplayLatestWhileConnected_DeadlockEmpty),
            ("testShareReplayLatestWhileConnected_DeadlockError", testShareReplayLatestWhileConnected_DeadlockError),
            ("testShareReplayLatestWhileConnected_DeadlockErrorAfterN", testShareReplayLatestWhileConnected_DeadlockErrorAfterN),
            ("testShareReplayLatestWhileConnected_Basic", testShareReplayLatestWhileConnected_Basic),
            ("testShareReplayLatestWhileConnected_Error", testShareReplayLatestWhileConnected_Error),
            ("testShareReplayLatestWhileConnected_Completed", testShareReplayLatestWhileConnected_Completed),
        ]
    }
}

extension ObservableTimeTest {
    static var allTests: [(String, (ObservableTimeTest) -> () throws -> Void)] {
        return [
            ("test_ThrottleTimeSpan_NotLatest_Completed", test_ThrottleTimeSpan_NotLatest_Completed),
            ("test_ThrottleTimeSpan_NotLatest_Never", test_ThrottleTimeSpan_NotLatest_Never),
            ("test_ThrottleTimeSpan_NotLatest_Empty", test_ThrottleTimeSpan_NotLatest_Empty),
            ("test_ThrottleTimeSpan_NotLatest_Error", test_ThrottleTimeSpan_NotLatest_Error),
            ("test_ThrottleTimeSpan_NotLatest_NoEnd", test_ThrottleTimeSpan_NotLatest_NoEnd),
            ("test_ThrottleTimeSpan_NotLatest_WithRealScheduler", test_ThrottleTimeSpan_NotLatest_WithRealScheduler),
            ("test_ThrottleTimeSpan_Completed", test_ThrottleTimeSpan_Completed),
            ("test_ThrottleTimeSpan_CompletedAfterDueTime", test_ThrottleTimeSpan_CompletedAfterDueTime),
            ("test_ThrottleTimeSpan_Never", test_ThrottleTimeSpan_Never),
            ("test_ThrottleTimeSpan_Empty", test_ThrottleTimeSpan_Empty),
            ("test_ThrottleTimeSpan_Error", test_ThrottleTimeSpan_Error),
            ("test_ThrottleTimeSpan_NoEnd", test_ThrottleTimeSpan_NoEnd),
            ("test_ThrottleTimeSpan_WithRealScheduler", test_ThrottleTimeSpan_WithRealScheduler),
            ("testSample_Sampler_SamplerThrows", testSample_Sampler_SamplerThrows),
            ("testSample_Sampler_Simple1", testSample_Sampler_Simple1),
            ("testSample_Sampler_Simple2", testSample_Sampler_Simple2),
            ("testSample_Sampler_Simple3", testSample_Sampler_Simple3),
            ("testSample_Sampler_SourceThrows", testSample_Sampler_SourceThrows),
            ("testInterval_TimeSpan_Basic", testInterval_TimeSpan_Basic),
            ("testInterval_TimeSpan_Zero", testInterval_TimeSpan_Zero),
            ("testInterval_TimeSpan_Zero_DefaultScheduler", testInterval_TimeSpan_Zero_DefaultScheduler),
            ("testInterval_TimeSpan_Disposed", testInterval_TimeSpan_Disposed),
            ("test_IntervalWithRealScheduler", test_IntervalWithRealScheduler),
            ("testTake_TakeZero", testTake_TakeZero),
            ("testTake_Some", testTake_Some),
            ("testTake_TakeLate", testTake_TakeLate),
            ("testTake_TakeError", testTake_TakeError),
            ("testTake_TakeNever", testTake_TakeNever),
            ("testTake_TakeTwice1", testTake_TakeTwice1),
            ("testTake_TakeDefault", testTake_TakeDefault),
            ("testDelaySubscription_TimeSpan_Simple", testDelaySubscription_TimeSpan_Simple),
            ("testDelaySubscription_TimeSpan_Error", testDelaySubscription_TimeSpan_Error),
            ("testDelaySubscription_TimeSpan_Dispose", testDelaySubscription_TimeSpan_Dispose),
            ("testSkip_Zero", testSkip_Zero),
            ("testSkip_Some", testSkip_Some),
            ("testSkip_Late", testSkip_Late),
            ("testSkip_Error", testSkip_Error),
            ("testSkip_Never", testSkip_Never),
            ("testIgnoreElements_DoesNotSendValues", testIgnoreElements_DoesNotSendValues),
            ("testBufferWithTimeOrCount_Basic", testBufferWithTimeOrCount_Basic),
            ("testBufferWithTimeOrCount_Error", testBufferWithTimeOrCount_Error),
            ("testBufferWithTimeOrCount_Disposed", testBufferWithTimeOrCount_Disposed),
            ("testBufferWithTimeOrCount_Default", testBufferWithTimeOrCount_Default),
            ("testWindowWithTimeOrCount_Basic", testWindowWithTimeOrCount_Basic),
            ("testWindowWithTimeOrCount_Error", testWindowWithTimeOrCount_Error),
            ("testWindowWithTimeOrCount_Disposed", testWindowWithTimeOrCount_Disposed),
            ("testTimeout_Empty", testTimeout_Empty),
            ("testTimeout_Error", testTimeout_Error),
            ("testTimeout_Never", testTimeout_Never),
            ("testTimeout_Duetime_Simple", testTimeout_Duetime_Simple),
            ("testTimeout_Duetime_Timeout_Exact", testTimeout_Duetime_Timeout_Exact),
            ("testTimeout_Duetime_Timeout", testTimeout_Duetime_Timeout),
            ("testTimeout_Duetime_Disposed", testTimeout_Duetime_Disposed),
            ("testTimeout_TimeoutOccurs_1", testTimeout_TimeoutOccurs_1),
            ("testTimeout_TimeoutOccurs_2", testTimeout_TimeoutOccurs_2),
            ("testTimeout_TimeoutOccurs_Never", testTimeout_TimeoutOccurs_Never),
            ("testTimeout_TimeoutOccurs_Completed", testTimeout_TimeoutOccurs_Completed),
            ("testTimeout_TimeoutOccurs_Error", testTimeout_TimeoutOccurs_Error),
            ("testTimeout_TimeoutOccurs_NextIsError", testTimeout_TimeoutOccurs_NextIsError),
            ("testTimeout_TimeoutNotOccurs_Completed", testTimeout_TimeoutNotOccurs_Completed),
            ("testTimeout_TimeoutNotOccurs_Error", testTimeout_TimeoutNotOccurs_Error),
            ("testTimeout_TimeoutNotOccurs", testTimeout_TimeoutNotOccurs),
            ("testDelay_TimeSpan_Simple1", testDelay_TimeSpan_Simple1),
            ("testDelay_TimeSpan_Simple2", testDelay_TimeSpan_Simple2),
            ("testDelay_TimeSpan_Simple3", testDelay_TimeSpan_Simple3),
            ("testDelay_TimeSpan_Error", testDelay_TimeSpan_Error),
            ("testDelay_TimeSpan_Completed", testDelay_TimeSpan_Completed),
            ("testDelay_TimeSpan_Error1", testDelay_TimeSpan_Error1),
            ("testDelay_TimeSpan_Error2", testDelay_TimeSpan_Error2),
            ("testDelay_TimeSpan_Real_Simple", testDelay_TimeSpan_Real_Simple),
            ("testDelay_TimeSpan_Real_Error1", testDelay_TimeSpan_Real_Error1),
            ("testDelay_TimeSpan_Real_Error2", testDelay_TimeSpan_Real_Error2),
            ("testDelay_TimeSpan_Real_Error3", testDelay_TimeSpan_Real_Error3),
            ("testDelay_TimeSpan_Positive", testDelay_TimeSpan_Positive),
            ("testDelay_TimeSpan_DefaultScheduler", testDelay_TimeSpan_DefaultScheduler),
        ]
    }
}

extension VariableTest {
    static var allTests: [(String, (VariableTest) -> () throws -> Void)] {
        return [
            ("testVariable_initialValues", testVariable_initialValues),
            ("testVariable_sendsCompletedOnDealloc", testVariable_sendsCompletedOnDealloc),
            ("testVariable_READMEExample", testVariable_READMEExample),
        ]
    }
}

extension ConcurrentDispatchQueueSchedulerTests {
    static var allTests: [(String, (ConcurrentDispatchQueueSchedulerTests) -> () throws -> Void)] {
        return [
            ("test_scheduleRelative", test_scheduleRelative),
            ("test_scheduleRelativeCancel", test_scheduleRelativeCancel),
            ("test_schedulePeriodic", test_schedulePeriodic),
            ("test_schedulePeriodicCancel", test_schedulePeriodicCancel),
        ]
    }
}

extension ObservableSubscriptionTests {
    static var allTests: [(String, (ObservableSubscriptionTests) -> () throws -> Void)] {
        return [
            ("testSubscribeOnNext", testSubscribeOnNext),
            ("testSubscribeOnError", testSubscribeOnError),
            ("testSubscribeOnCompleted", testSubscribeOnCompleted),
            ("testDisposed", testDisposed),
        ]
    }
}

extension ObservableStandardSequenceOperatorsTest {
    static var allTests: [(String, (ObservableStandardSequenceOperatorsTest) -> () throws -> Void)] {
        return [
            ("test_filterComplete", test_filterComplete),
            ("test_filterTrue", test_filterTrue),
            ("test_filterFalse", test_filterFalse),
            ("test_filterDisposed", test_filterDisposed),
            ("testTakeWhile_Complete_Before", testTakeWhile_Complete_Before),
            ("testTakeWhile_Complete_After", testTakeWhile_Complete_After),
            ("testTakeWhile_Error_Before", testTakeWhile_Error_Before),
            ("testTakeWhile_Error_After", testTakeWhile_Error_After),
            ("testTakeWhile_Dispose_Before", testTakeWhile_Dispose_Before),
            ("testTakeWhile_Dispose_After", testTakeWhile_Dispose_After),
            ("testTakeWhile_Zero", testTakeWhile_Zero),
            ("testTakeWhile_Throw", testTakeWhile_Throw),
            ("testTakeWhile_Index1", testTakeWhile_Index1),
            ("testTakeWhile_Index2", testTakeWhile_Index2),
            ("testTakeWhile_Index_Error", testTakeWhile_Index_Error),
            ("testTakeWhile_Index_SelectorThrows", testTakeWhile_Index_SelectorThrows),
            ("testMap_Never", testMap_Never),
            ("testMap_Empty", testMap_Empty),
            ("testMap_Range", testMap_Range),
            ("testMap_Error", testMap_Error),
            ("testMap_Dispose", testMap_Dispose),
            ("testMap_SelectorThrows", testMap_SelectorThrows),
            ("testMap1_Never", testMap1_Never),
            ("testMap1_Empty", testMap1_Empty),
            ("testMap1_Range", testMap1_Range),
            ("testMap1_Error", testMap1_Error),
            ("testMap1_Dispose", testMap1_Dispose),
            ("testMap1_SelectorThrows", testMap1_SelectorThrows),
            ("testMap_DisposeOnCompleted", testMap_DisposeOnCompleted),
            ("testMap1_DisposeOnCompleted", testMap1_DisposeOnCompleted),
            ("testMapCompose_Never", testMapCompose_Never),
            ("testMapCompose_Empty", testMapCompose_Empty),
            ("testMapCompose_Range", testMapCompose_Range),
            ("testMapCompose_Error", testMapCompose_Error),
            ("testMapCompose_Dispose", testMapCompose_Dispose),
            ("testMapCompose_Selector1Throws", testMapCompose_Selector1Throws),
            ("testMapCompose_Selector2Throws", testMapCompose_Selector2Throws),
            ("testFlatMapFirst_Complete", testFlatMapFirst_Complete),
            ("testFlatMapFirst_Complete_InnerNotComplete", testFlatMapFirst_Complete_InnerNotComplete),
            ("testFlatMapFirst_Complete_OuterNotComplete", testFlatMapFirst_Complete_OuterNotComplete),
            ("testFlatMapFirst_Complete_ErrorOuter", testFlatMapFirst_Complete_ErrorOuter),
            ("testFlatMapFirst_Error_Inner", testFlatMapFirst_Error_Inner),
            ("testFlatMapFirst_Dispose", testFlatMapFirst_Dispose),
            ("testFlatMapFirst_SelectorThrows", testFlatMapFirst_SelectorThrows),
            ("testFlatMapFirst_UseFunction", testFlatMapFirst_UseFunction),
            ("testFlatMap_Complete", testFlatMap_Complete),
            ("testFlatMap_Complete_InnerNotComplete", testFlatMap_Complete_InnerNotComplete),
            ("testFlatMap_Complete_OuterNotComplete", testFlatMap_Complete_OuterNotComplete),
            ("testFlatMap_Complete_ErrorOuter", testFlatMap_Complete_ErrorOuter),
            ("testFlatMap_Error_Inner", testFlatMap_Error_Inner),
            ("testFlatMap_Dispose", testFlatMap_Dispose),
            ("testFlatMap_SelectorThrows", testFlatMap_SelectorThrows),
            ("testFlatMap_UseFunction", testFlatMap_UseFunction),
            ("testFlatMapIndex_Index", testFlatMapIndex_Index),
            ("testFlatMapWithIndex_Complete", testFlatMapWithIndex_Complete),
            ("testFlatMapWithIndex_Complete_InnerNotComplete", testFlatMapWithIndex_Complete_InnerNotComplete),
            ("testFlatMapWithIndex_Complete_OuterNotComplete", testFlatMapWithIndex_Complete_OuterNotComplete),
            ("testFlatMapWithIndex_Complete_ErrorOuter", testFlatMapWithIndex_Complete_ErrorOuter),
            ("testFlatMapWithIndex_Error_Inner", testFlatMapWithIndex_Error_Inner),
            ("testFlatMapWithIndex_Dispose", testFlatMapWithIndex_Dispose),
            ("testFlatMapWithIndex_SelectorThrows", testFlatMapWithIndex_SelectorThrows),
            ("testFlatMapWithIndex_UseFunction", testFlatMapWithIndex_UseFunction),
            ("testTake_Complete_After", testTake_Complete_After),
            ("testTake_Complete_Same", testTake_Complete_Same),
            ("testTake_Complete_Before", testTake_Complete_Before),
            ("testTake_Error_After", testTake_Error_After),
            ("testTake_Error_Same", testTake_Error_Same),
            ("testTake_Error_Before", testTake_Error_Before),
            ("testTake_Dispose_Before", testTake_Dispose_Before),
            ("testTake_Dispose_After", testTake_Dispose_After),
            ("testTake_0_DefaultScheduler", testTake_0_DefaultScheduler),
            ("testTake_Take1", testTake_Take1),
            ("testTake_DecrementCountsFirst", testTake_DecrementCountsFirst),
            ("testTakeLast_Complete_Less", testTakeLast_Complete_Less),
            ("testTakeLast_Complete_Same", testTakeLast_Complete_Same),
            ("testTakeLast_Complete_More", testTakeLast_Complete_More),
            ("testTakeLast_Error_Less", testTakeLast_Error_Less),
            ("testTakeLast_Error_Same", testTakeLast_Error_Same),
            ("testTakeLast_Error_More", testTakeLast_Error_More),
            ("testTakeLast_0_DefaultScheduler", testTakeLast_0_DefaultScheduler),
            ("testTakeLast_TakeLast1", testTakeLast_TakeLast1),
            ("testTakeLast_DecrementCountsFirst", testTakeLast_DecrementCountsFirst),
            ("testSkip_Complete_After", testSkip_Complete_After),
            ("testSkip_Complete_Some", testSkip_Complete_Some),
            ("testSkip_Complete_Before", testSkip_Complete_Before),
            ("testSkip_Complete_Zero", testSkip_Complete_Zero),
            ("testSkip_Error_After", testSkip_Error_After),
            ("testSkip_Error_Same", testSkip_Error_Same),
            ("testSkip_Error_Before", testSkip_Error_Before),
            ("testSkip_Dispose_Before", testSkip_Dispose_Before),
            ("testSkip_Dispose_After", testSkip_Dispose_After),
            ("testSkipWhile_Complete_Before", testSkipWhile_Complete_Before),
            ("testSkipWhile_Complete_After", testSkipWhile_Complete_After),
            ("testSkipWhile_Error_Before", testSkipWhile_Error_Before),
            ("testSkipWhile_Error_After", testSkipWhile_Error_After),
            ("testSkipWhile_Dispose_Before", testSkipWhile_Dispose_Before),
            ("testSkipWhile_Dispose_After", testSkipWhile_Dispose_After),
            ("testSkipWhile_Zero", testSkipWhile_Zero),
            ("testSkipWhile_Throw", testSkipWhile_Throw),
            ("testSkipWhile_Index", testSkipWhile_Index),
            ("testSkipWhile_Index_Throw", testSkipWhile_Index_Throw),
            ("testSkipWhile_Index_SelectorThrows", testSkipWhile_Index_SelectorThrows),
            ("testElementAt_Complete_After", testElementAt_Complete_After),
            ("testElementAt_Complete_Before", testElementAt_Complete_Before),
            ("testElementAt_Error_After", testElementAt_Error_After),
            ("testElementAt_Error_Before", testElementAt_Error_Before),
            ("testElementAt_Dispose_Before", testElementAt_Dispose_Before),
            ("testElementAt_Dispose_After", testElementAt_Dispose_After),
            ("testElementAt_First", testElementAt_First),
            ("testSingle_Empty", testSingle_Empty),
            ("testSingle_One", testSingle_One),
            ("testSingle_Many", testSingle_Many),
            ("testSingle_Error", testSingle_Error),
            ("testSingle_DecrementCountsFirst", testSingle_DecrementCountsFirst),
            ("testSinglePredicate_Empty", testSinglePredicate_Empty),
            ("testSinglePredicate_One", testSinglePredicate_One),
            ("testSinglePredicate_Many", testSinglePredicate_Many),
            ("testSinglePredicate_Error", testSinglePredicate_Error),
            ("testSinglePredicate_Throws", testSinglePredicate_Throws),
            ("testSinglePredicate_DecrementCountsFirst", testSinglePredicate_DecrementCountsFirst),
        ]
    }
}

extension ObservableAggregateTest {
    static var allTests: [(String, (ObservableAggregateTest) -> () throws -> Void)] {
        return [
            ("test_AggregateWithSeed_Empty", test_AggregateWithSeed_Empty),
            ("test_AggregateWithSeed_Return", test_AggregateWithSeed_Return),
            ("test_AggregateWithSeed_Throw", test_AggregateWithSeed_Throw),
            ("test_AggregateWithSeed_Never", test_AggregateWithSeed_Never),
            ("test_AggregateWithSeed_Range", test_AggregateWithSeed_Range),
            ("test_AggregateWithSeed_AccumulatorThrows", test_AggregateWithSeed_AccumulatorThrows),
            ("test_AggregateWithSeedAndResult_Empty", test_AggregateWithSeedAndResult_Empty),
            ("test_AggregateWithSeedAndResult_Return", test_AggregateWithSeedAndResult_Return),
            ("test_AggregateWithSeedAndResult_Throw", test_AggregateWithSeedAndResult_Throw),
            ("test_AggregateWithSeedAndResult_Never", test_AggregateWithSeedAndResult_Never),
            ("test_AggregateWithSeedAndResult_Range", test_AggregateWithSeedAndResult_Range),
            ("test_AggregateWithSeedAndResult_AccumulatorThrows", test_AggregateWithSeedAndResult_AccumulatorThrows),
            ("test_AggregateWithSeedAndResult_SelectorThrows", test_AggregateWithSeedAndResult_SelectorThrows),
            ("test_ToArrayWithSingleItem_Return", test_ToArrayWithSingleItem_Return),
            ("test_ToArrayWithMultipleItems_Return", test_ToArrayWithMultipleItems_Return),
            ("test_ToArrayWithNoItems_Empty", test_ToArrayWithNoItems_Empty),
            ("test_ToArrayWithSingleItem_Never", test_ToArrayWithSingleItem_Never),
            ("test_ToArrayWithImmediateError_Throw", test_ToArrayWithImmediateError_Throw),
            ("test_ToArrayWithMultipleItems_Throw", test_ToArrayWithMultipleItems_Throw),
        ]
    }
}

XCTMain([
    testCase(SubjectConcurrencyTest.allTests),
    // testCase(ObservableBlockingTest.allTests),
    testCase(BehaviorSubjectTest.allTests),
    testCase(DisposableTest.allTests),
    testCase(ObservableConcurrencyTest.allTests),
    testCase(ObservableDebugTest.allTests),
    testCase(AnonymousObservableTests.allTests),
    testCase(ObservableCreationTests.allTests),
    testCase(MainSchedulerTest.allTests),
    testCase(VirtualSchedulerTest.allTests),
    testCase(AssumptionsTest.allTests),
    testCase(QueueTest.allTests),
    testCase(CurrentThreadSchedulerTest.allTests),
    testCase(HistoricalSchedulerTest.allTests),
    testCase(ObservableMultipleTest.allTests),
    testCase(BagTest.allTests),
    testCase(ObservableSingleTest.allTests),
    testCase(ObserverTests.allTests),
    testCase(PublishSubjectTest.allTests),
    testCase(ReplaySubjectTest.allTests),
    testCase(ObservableBindingTest.allTests),
    // testCase(ObservableTimeTest.allTests),
    testCase(VariableTest.allTests),
    testCase(ConcurrentDispatchQueueSchedulerTests.allTests),
    testCase(ObservableSubscriptionTests.allTests),
    testCase(ObservableStandardSequenceOperatorsTest.allTests),
    testCase(ObservableAggregateTest.allTests),
])
