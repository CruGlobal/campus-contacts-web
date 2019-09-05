import React, { useContext } from 'react';
import { useTranslation } from 'react-i18next';
import moment from 'moment';

import Card from '../../components/Card';
import AppContext from '../../../appContext';
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

const StepsOfFaithPage = () => {
    const { t } = useTranslation('insights');
    const { orgId }: any = useContext(AppContext);

    return (
        <div>
            <ImpactInfo
                query={GET_IMPACT_REPORT_TAKEN}
                text={report =>
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
                    mapData={data =>
                        data.community.report.stagesReport.map(
                            (entry: any) => ({
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
                    query={GET_STEPS_COMPLETED_REPORT}
                    variables={{ id: orgId }}
                    mapData={data =>
                        data.community.report.daysReport.map((row: any) => ({
                            ['total']: row.othersStepsCompletedCount,
                            ['stages']: row.stageResults.map((stage: any) => ({
                                name: stage.othersStepsCompletedCount,
                                count: stage.stage.name,
                            })),
                            ['date']: row.date,
                        }))
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
                    query={GET_STAGES_REPORT}
                    mapData={data =>
                        data.community.report.stagesReport.map((row: any) => ({
                            [t(
                                'stepsOfFaith.legendLabel',
                            )]: row.othersStepsAddedCount,
                            [t('stage')]: row.stage.name.toUpperCase(),
                        }))
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
                text={report =>
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
                    query={GET_STAGES_PEOPLE_REPORT}
                    mapData={data =>
                        data.community.report.stagesReport.map((row: any) => ({
                            [t('stepsOfFaith.peopleLabel')]: row.contactCount,
                            [t('stage')]: row.stage.name.toUpperCase(),
                        }))
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
