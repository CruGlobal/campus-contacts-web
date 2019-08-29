import React, { useContext } from 'react';
import { useTranslation } from 'react-i18next';
import moment from 'moment';

import Card from '../../components/Card';
import AppContext from '../../appContext';
import StagesSummary from '../../components/StagesSummary';
import ImpactInfo from '../../components/ImpactInfo';
import FiltersChart from '../../components/FiltersChart';

import {
    INTERACTIONS_TOTAL_REPORT,
    INTERACTIONS_TOTAL_COMPLETED_REPORT,
    INTERACTIONS_COMPLETED_REPORT,
} from './queries';

const InteractionsPage = () => {
    const { t } = useTranslation('insights');
    const { orgId }: any = useContext(AppContext);

    return (
        <div>
            <ImpactInfo
                query={INTERACTIONS_TOTAL_REPORT}
                text={report =>
                    t('interactions.taken', {
                        count: report.community.impactReport.interactionsCount,
                        people:
                            report.community.impactReport
                                .interactionsReceiversCount,
                    })
                }
                variables={{ id: orgId }}
            />
            <Card title={t('interactions.totalCompleted')}>
                <StagesSummary
                    query={INTERACTIONS_TOTAL_COMPLETED_REPORT}
                    variables={{ id: orgId }}
                    mapData={data =>
                        data.community.report.interactions.map(
                            (entry: any) => ({
                                stage: entry.interactionType.name,
                                icon: entry.interactionType.name
                                    .toLowerCase()
                                    .split(' ')
                                    .join('-'),
                                count: entry.interactionCount,
                            }),
                        )
                    }
                />
            </Card>
            <Card
                title={t('interactions.completed')}
                subtitle={t('interactions.completedSubtitle')}
            >
                <FiltersChart
                    query={INTERACTIONS_COMPLETED_REPORT}
                    variables={{ id: orgId }}
                    mapData={data =>
                        data.community.report.daysReport.map((row: any) => ({
                            ['total']: row.interactionsCount,
                            ['stages']: row.interactionResults.map(
                                (stage: any) => ({
                                    name: stage.interactionType.name,
                                    count: stage.count,
                                }),
                            ),
                            ['date']: row.date,
                        }))
                    }
                    currentDate={moment().toDate()}
                    label={t('interactions.legend')}
                />
            </Card>
        </div>
    );
};

export default InteractionsPage;

InteractionsPage.propTypes = {};
