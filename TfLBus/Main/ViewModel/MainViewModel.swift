import MainUseCases

public final class MainViewModelDefault {

    private var stopAndLineIdsSetterUseCase: StopAndLineIdsSetterUseCase

    public init(stopAndLineIdsSetterUseCase: StopAndLineIdsSetterUseCase) {
        self.stopAndLineIdsSetterUseCase = stopAndLineIdsSetterUseCase

        setupStopAndLineId()
    }

    private func setupStopAndLineId() {
        stopAndLineIdsSetterUseCase.set(stopId: "490001302S")
        stopAndLineIdsSetterUseCase.set(lineId: "271")

//        stopAndLineIdsSetterUseCase.set(stopId: "490000119F")
//        stopAndLineIdsSetterUseCase.set(lineId: "38")
    }
}

extension MainViewModelDefault: MainViewModel {
    public var title: String { return  "TfL Bus" }
}
