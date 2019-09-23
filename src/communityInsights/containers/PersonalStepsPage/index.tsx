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

const PersonalStepsPage = () => {
    const { t } = useTranslation('insights');
    const { orgId } = useContext(AppContext);

    return (
        <div>
            <ImpactInfo
                query={GET_IMPACT_REPORT_STEPS_TAKEN}
                text={report =>
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
                    mapData={data =>
                        data.community.report.stagesReport.map(
                            (entry: any) => ({
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
                    mapData={data =>
                        data.community.report.daysReport.map((row: any) => ({
                            ['total']: row.personalStepsCompletedCount,
                            ['stages']: row.stageResults.map((stage: any) => ({
                                name: stage.stage.name,
                                count: stage.personalStepsCompletedCount,
                            })),
                            ['date']: row.date,
                        }))
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
                    mapData={data =>
                        data.community.report.stagesReport.map((row: any) => ({
                            [t('personalSteps.label')]: row.stage
                                .personalStepsAddedCount,
                            [t('stage')]: row.stage.name.toUpperCase(),
                        }))
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
                text={report =>
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
                    mapData={data =>
                        data.community.report.stagesReport.map((row: any) => ({
                            [t('members')]: row.memberCount,
                            [t('stage')]: row.stage.name.toUpperCase(),
                        }))
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