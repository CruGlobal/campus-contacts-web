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
    GET_IMPACT_REPORT_MOVED,
    GET_IMPACT_REPORT_STEPS_TAKEN,
    GET_STAGES_REPORT_MEMBER_COUNT,
    GET_STEPS_COMPLETED_REPORT,
    GET_STAGES_REPORT_STEPS_ADDED,
    GET_TOTAL_STEPS_COMPLETED_SUMMARY,
} from './queries';
// GET_IMPACT_REPORT_STEPS_TAKEN INTERFACES
import { impactReportPersonalStepsCompletedCount } from './__generated__/impactReportPersonalStepsCompletedCount';
// GET_TOTAL_STEPS_COMPLETED_SUMMARY INTERFACES
import {
    communityReportStagesPersonalStepsCompleted,
    communityReportStagesPersonalStepsCompleted_community_report_stagesReport as communityReportStagesPersonalStepsCompletedEntry,
} from './__generated__/communityReportStagesPersonalStepsCompleted';
// GET_STEPS_COMPLETED_REPORT INTERFACES
import {
    communityReportDaysPersonalSteps,
    communityReportDaysPersonalSteps_community_report_daysReport as communityReportDaysPersonalRow,
    communityReportDaysPersonalSteps_community_report_daysReport_stageResults as communityReportDaysPersonalStage,
} from './__generated__/communityReportDaysPersonalSteps';
// GET_STAGES_REPORT_STEPS_ADDED INTERFACES
import {
    communityReportStagesPersonalStepsAdded,
    communityReportStagesPersonalStepsAdded_community_report_stagesReport as communityReportStagesPersonalStepsAddedRow,
} from './__generated__/communityReportStagesPersonalStepsAdded';
// GET_IMPACT_REPORT_MOVED INTERFACES
import { impactReportStageProgressionCount } from './__generated__/impactReportStageProgressionCount';
// GET_STAGES_REPORT_MEMBER_COUNT INTERFACES
import {
    communityReportStagesPersonalMemberCount,
    communityReportStagesPersonalMemberCount_community_report_stagesReport as communityReportStagesPersonalMemberCountRow,
} from './__generated__/communityReportStagesPersonalMemberCount';

const PersonalStepsPage = () => {
    const { t } = useTranslation('insights');
    const { orgId } = useContext(AppContext);

    return (
        <div>
            <ImpactInfo
                query={GET_IMPACT_REPORT_STEPS_TAKEN}
                text={(report: impactReportPersonalStepsCompletedCount) =>
                    t('personalSteps.taken', {
                        count:
                            report.community.impactReport
                                .personalStepsCompletedCount,
                    })
                }
                variables={{ id: orgId }}
            />
            <Card title={t('personalSteps.completedTotal')}>
                <StagesSummary
                    query={GET_TOTAL_STEPS_COMPLETED_SUMMARY}
                    variables={{ id: orgId }}
                    mapData={(
                        data: communityReportStagesPersonalStepsCompleted,
                    ) =>
                        data.community.report.stagesReport.map(
                            (
                                entry: communityReportStagesPersonalStepsCompletedEntry,
                            ) => ({
                                stage: entry.stage.name,
                                icon: entry.stage.name
                                    .toLowerCase()
                                    .replace(' ', '-'),
                                count: entry.personalStepsCompletedCount,
                            }),
                        )
                    }
                />
            </Card>
            <Card
                title={t('personalSteps.completed')}
                subtitle={t('personalSteps.completedSubtitle')}
            >
                <FiltersChart
                    query={GET_STEPS_COMPLETED_REPORT}
                    variables={{ id: orgId }}
                    mapData={(data: communityReportDaysPersonalSteps) =>
                        data.community.report.daysReport.map(
                            (row: communityReportDaysPersonalRow) => ({
                                ['total']: row.personalStepsCompletedCount,
                                ['stages']: row.stageResults.map(
                                    (
                                        stage: communityReportDaysPersonalStage,
                                    ) => ({
                                        name: stage.stage.name,
                                        count:
                                            stage.personalStepsCompletedCount,
                                    }),
                                ),
                                ['date']: row.date,
                            }),
                        )
                    }
                    currentDate={moment().toDate()}
                    label={t('personalSteps.legend')}
                />
            </Card>
            <Card
                title={t('personalSteps.added')}
                subtitle={t('personalSteps.addedSubtitle')}
            >
                <StepsChart
                    query={GET_STAGES_REPORT_STEPS_ADDED}
                    mapData={(data: communityReportStagesPersonalStepsAdded) =>
                        data.community.report.stagesReport.map(
                            (
                                row: communityReportStagesPersonalStepsAddedRow,
                            ) => ({
                                [t(
                                    'personalSteps.label',
                                )]: row.personalStepsAddedCount,
                                [t('stage')]: row.stage.name.toUpperCase(),
                            }),
                        )
                    }
                    label={t('personalSteps.label')}
                    index={t('stage')}
                    variables={{
                        period: 'P10Y',
                        id: orgId,
                        endDate: moment().format(),
                    }}
                />
            </Card>

            <ImpactInfo
                query={GET_IMPACT_REPORT_MOVED}
                text={(report: impactReportStageProgressionCount) =>
                    t('personalSteps.reached', {
                        count:
                            report.community.impactReport.stageProgressionCount,
                    })
                }
                variables={{ id: orgId }}
            />
            <Card
                title={t('personalSteps.members')}
                subtitle={t('personalSteps.membersSubtitle')}
            >
                <StepsChart
                    query={GET_STAGES_REPORT_MEMBER_COUNT}
                    mapData={(data: communityReportStagesPersonalMemberCount) =>
                        data.community.report.stagesReport.map(
                            (
                                row: communityReportStagesPersonalMemberCountRow,
                            ) => ({
                                [t('members')]: row.memberCount,
                                [t('stage')]: row.stage.name.toUpperCase(),
                            }),
                        )
                    }
                    label={t('members')}
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

export default PersonalStepsPage;
