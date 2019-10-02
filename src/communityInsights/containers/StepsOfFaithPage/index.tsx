import React, { useContext } from 'react';
import { useTranslation } from 'react-i18next';
import moment from 'moment';

import Card from '../../components/Card';
import { AppContext } from '../../../appContext';
import StagesSummary from '../../components/StagesSummary';
import StepsChart from '../../components/StepsChart';
import ImpactInfo from '../../components/ImpactInfo';
import FiltersChart from '../../components/FiltersChart';

import {
    GET_IMPACT_REPORT_TAKEN,
    GET_TOTAL_STEPS_COMPLETED_REPORT,
    GET_STEPS_COMPLETED_REPORT,
    GET_STAGES_REPORT,
    GET_IMPACT_REPORT_REACHED,
    GET_STAGES_PEOPLE_REPORT,
} from './queries';
// GET_IMPACT_REPORT_TAKEN INTERFACES
import { impactReportOtherStepsCompleted as impactsOtherReport } from './__generated__/impactReportOtherStepsCompleted';
// GET_TOTAL_STEPS_COMPLETED_REPORT INTERFACES
import {
    communityReportStagesOthersStepsCompleted,
    communityReportStagesOthersStepsCompleted_community_report_stagesReport as communityReportEntry,
} from './__generated__/communityReportStagesOthersStepsCompleted';
// GET_STEPS_COMPLETED_REPORT INTERFACES
import {
    communityReportDaysOthersSteps as communityDaysOtherReport,
    communityReportDaysOthersSteps_community_report_daysReport as communityDaysReportRow,
    communityReportDaysOthersSteps_community_report_daysReport_stageResults as communityDaysReportStage,
} from './__generated__/communityReportDaysOthersSteps';
// GET_STAGES_REPORT INTERFACES
import {
    communityReportStagesOthersStepsAdded,
    communityReportStagesOthersStepsAdded_community_report_stagesReport as communityStepsAddedStageReportRow,
} from './__generated__/communityReportStagesOthersStepsAdded';
// GET_IMPACT_REPORT_REACHED INTERFACES
import { impactReportMembersStageProgressionCount as impactMembersReport } from './__generated__/impactReportMembersStageProgressionCount';
// GET_STAGES_PEOPLE_REPORT INTERFACES
import {
    communityReportStagesOthersContactCount,
    communityReportStagesOthersContactCount_community_report_stagesReport as communityReportStagesContactCountRow,
} from './__generated__/communityReportStagesOthersContactCount';

const StepsOfFaithPage = () => {
    const { t } = useTranslation('insights');
    const { orgId } = useContext(AppContext);

    return (
        <div>
            <ImpactInfo
                query={GET_IMPACT_REPORT_TAKEN}
                text={(report: impactsOtherReport) =>
                    t('stepsOfFaith.taken', {
                        count:
                            report.community.impactReport
                                .othersStepsCompletedCount,
                        people:
                            report.community.impactReport
                                .othersStepsReceiversCompletedCount,
                    })
                }
                variables={{ id: orgId }}
            />
            <Card title={t('stepsOfFaith.totalCompleted')}>
                <StagesSummary
                    query={GET_TOTAL_STEPS_COMPLETED_REPORT}
                    variables={{ id: orgId }}
                    mapData={(
                        data: communityReportStagesOthersStepsCompleted,
                    ) =>
                        data.community.report.stagesReport.map(
                            (entry: communityReportEntry) => ({
                                stage: entry.stage.name,
                                icon: entry.stage.name
                                    .toLowerCase()
                                    .replace(' ', '-'),
                                count: entry.othersStepsCompletedCount,
                            }),
                        )
                    }
                />
            </Card>
            <Card
                title={t('stepsOfFaith.completed')}
                subtitle={t('stepsOfFaith.completedSubtitle')}
            >
                <FiltersChart
                    nullContent={'stepsOfFaithCompleted'}
                    query={GET_STEPS_COMPLETED_REPORT}
                    variables={{ id: orgId }}
                    mapData={(data: communityDaysOtherReport) =>
                        data.community.report.daysReport.map(
                            (row: communityDaysReportRow) => ({
                                ['total']: row.othersStepsCompletedCount,
                                ['stages']: row.stageResults.map(
                                    (stage: communityDaysReportStage) => ({
                                        name: stage.othersStepsCompletedCount,
                                        count: stage.stage.name,
                                    }),
                                ),
                                ['date']: row.date,
                            }),
                        )
                    }
                    currentDate={moment().toDate()}
                    label={t('stepsOfFaith.legend')}
                />
            </Card>
            <Card
                title={t('stepsOfFaith.added')}
                subtitle={t('stepsOfFaith.addedSubtitle')}
            >
                <StepsChart
                    nullContent={'stepsOfFaithAdded'}
                    query={GET_STAGES_REPORT}
                    mapData={(data: communityReportStagesOthersStepsAdded) =>
                        data.community.report.stagesReport.map(
                            (row: communityStepsAddedStageReportRow) => ({
                                [t(
                                    'stepsOfFaith.legendLabel',
                                )]: row.othersStepsAddedCount,
                                [t('stage')]: row.stage.name.toUpperCase(),
                            }),
                        )
                    }
                    label={t('stepsOfFaith.legendLabel')}
                    index={t('stage')}
                    variables={{
                        period: 'P10Y',
                        id: orgId,
                        endDate: moment().format(),
                    }}
                />
            </Card>
            <ImpactInfo
                query={GET_IMPACT_REPORT_REACHED}
                text={(report: impactMembersReport) =>
                    t('stepsOfFaith.reached', {
                        count:
                            report.community.impactReport
                                .membersStageProgressionCount,
                    })
                }
                variables={{ id: orgId }}
            />
            <Card
                title={t('stepsOfFaith.people')}
                subtitle={t('stepsOfFaith.peopleSubtitle')}
            >
                <StepsChart
                    nullContent={'peopleStages'}
                    query={GET_STAGES_PEOPLE_REPORT}
                    mapData={(data: communityReportStagesOthersContactCount) =>
                        data.community.report.stagesReport.map(
                            (row: communityReportStagesContactCountRow) => ({
                                [t(
                                    'stepsOfFaith.peopleLabel',
                                )]: row.contactCount,
                                [t('stage')]: row.stage.name.toUpperCase(),
                            }),
                        )
                    }
                    label={t('stepsOfFaith.peopleLabel')}
                    index={t('stage')}
                    variables={{
                        period: 'P10Y',
                        id: orgId,
                        endDate: moment().format(),
                    }}
                />
            </Card>
        </div>
    );
};

export default StepsOfFaithPage;
