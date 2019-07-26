import React, { useContext } from 'react';
import { useTranslation } from 'react-i18next';
import moment from 'moment';
import _ from 'lodash';

import Card from '../../components/Card';
import AppContext from '../../appContext';
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
    const { orgId } = useContext(AppContext);

    return (
        <div>
            <ImpactInfo
                query={GET_IMPACT_REPORT_TAKEN}
                text={report =>
                    t('stepsOfFaith.taken', {
                        count: report.impactReport.stepsCount,
                        people: report.impactReport.receiversCount,
                    })
                }
                variables={{ organizationId: orgId }}
            />
            <Card title={t('stepsOfFaith.totalCompleted')}>
                <StagesSummary
                    query={GET_TOTAL_STEPS_COMPLETED_REPORT}
                    variables={{
                        organizationId: orgId,
                    }}
                    mapData={data =>
                        data.communityReport.communityStagesReport.map(
                            entry => ({
                                stage: entry.pathwayStage,
                                icon: entry.pathwayStage
                                    .toLowerCase()
                                    .replace(' ', '-'),
                                count: entry.otherStepsCompletedCount,
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
                    mapData={data =>
                        data.communityReport.dayReport.map(row => ({
                            ['total']: row.stepsWithOthersStepsCompletedCount,
                            ['stages']: row.communityStagesReport.map(
                                stage => ({
                                    name: stage.pathwayStage,
                                    count:
                                        stage.stepsWithOthersStepsCompletedCount,
                                }),
                            ),
                            ['date']: row.date.substring(0, 2),
                        }))
                    }
                    countAverage={data =>
                        Math.floor(_.sumBy(data, 'total') / data.length)
                    }
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
                        data.organizationPathwayStagesReport.map(row => ({
                            [t(
                                'stepsOfFaith.legendLabel',
                            )]: row.othersStepsAddedCount,
                            [t('stage')]: row.pathwayStage.name.toUpperCase(),
                        }))
                    }
                    label={t('stepsOfFaith.legendLabel')}
                    index={t('stage')}
                    variables={{
                        period: '',
                        organizationId: orgId,
                        endDate: moment().format(),
                    }}
                />
            </Card>
            <ImpactInfo
                query={GET_IMPACT_REPORT_REACHED}
                text={report =>
                    t('stepsOfFaith.reached', {
                        count: report.impactReport.stepsCount,
                    })
                }
                variables={{ organizationId: orgId }}
            />
            <Card
                title={t('stepsOfFaith.people')}
                subtitle={t('stepsOfFaith.peopleSubtitle')}
            >
                <StepsChart
                    query={GET_STAGES_PEOPLE_REPORT}
                    mapData={data =>
                        data.organizationPathwayStagesReport.map(row => ({
                            [t('stepsOfFaith.peopleLabel')]: row.memberCount,
                            [t('stage')]: row.pathwayStage.name.toUpperCase(),
                        }))
                    }
                    label={t('stepsOfFaith.peopleLabel')}
                    index={t('stage')}
                    variables={{
                        period: '',
                        organizationId: orgId,
                        endDate: moment().format(),
                    }}
                />
            </Card>
        </div>
    );
};

export default StepsOfFaithPage;

StepsOfFaithPage.propTypes = {};
