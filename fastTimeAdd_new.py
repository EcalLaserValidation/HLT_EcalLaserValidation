
process.options = cms.untracked.PSet(
    wantSummary = cms.untracked.bool( True ),
    numberOfThreads = cms.untracked.uint32( 4 ),
    numberOfStreams = cms.untracked.uint32( 0 ),
    sizeOfStackForThreadsInKB = cms.untracked.uint32( 10*1024 )
)



# FastTimerServiceClient                                                                                                                                                                                          
process.fastTimerServiceClient = cms.EDProducer( "FastTimerServiceClient",
    dqmPath = cms.untracked.string( "HLT/TimerService" )
)

# DQM file saver                                                                                                                                                                                                  
process.dqmFileSaver = cms.EDAnalyzer( "DQMFileSaver",
    convention        = cms.untracked.string( "Offline" ),
    workflow          = cms.untracked.string( "/HLT/FastTimerService/All" ),
    dirName           = cms.untracked.string( "." ),
    saveByRun         = cms.untracked.int32(1),
    saveByLumiSection = cms.untracked.int32(-1),
    saveByEvent       = cms.untracked.int32(-1),
    saveByTime        = cms.untracked.int32(-1),
    saveByMinute      = cms.untracked.int32(-1),
    saveAtJobEnd      = cms.untracked.bool(False),
    forceRunNumber    = cms.untracked.int32(-1),
)

process.TimingOutput = cms.EndPath( process.fastTimerServiceClient + process.dqmFileSaver )


process.GlobalTag.toGet = cms.VPSet(
  cms.PSet(record = cms.string("EcalLaserAPDPNRatiosRcd"),
           tag = cms.string("EcalLaserAPDPNRatios_TOADAPT_beginning_at_1"),

#           connect = cms.string("sqlite_file:/afs/cern.ch/work/e/ecaltrg/public/dropbox/DBLaser/DBLaser_292925.db")
           connect = cms.string("sqlite_file:/afs/cern.ch/work/e/ecaltrg/public/dropbox/DBLaser/DBLaser_TOADAPT_moved_to_1.db")
          )
)
