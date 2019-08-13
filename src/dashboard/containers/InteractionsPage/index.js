import React, { useContext } from 'react';
import { useTranslation } from 'react-i18next';
import moment from 'moment';
import _ from 'lodash';

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
    const { orgId } = useContext(AppContext);

    return (
        <div>
            <ImpactInfo
                query={INTERACTIONS_TOTAL_REPORT}
                text={report =>
                    t('interactions.taken', {
                        count: report.impactReport.interactionsCount,
                        people: report.impactReport.interactionsReceiversCount,
                    })
                }
                variables={{ communityId: orgId }}
            />
            <Card title={t('interactions.totalCompleted')}>
                <StagesSummary
                    query={INTERACTIONS_TOTAL_COMPLETED_REPORT}
                    variables={{
                        communityIds: [orgId],
                    }}
                    mapData={data =>
                        data.communitiesReport[0].interactions.map(entry => ({
                            stage: entry.interactionType.name,
                            icon: entry.interactionType.name
                                .toLowerCase()
                                .split(' ')
                                .join('-'),
                            count: entry.interactionCount,
                        }))
                    }
                />
            </Card>
            <Card
                title={t('interactions.completed')}
                subtitle={t('interactions.completedSubtitle')}
            >
                <FiltersChart
                    query={INTERACTIONS_COMPLETED_REPORT}
                    variables={{
                        communityIds: [orgId],
                    }}
                    mapData={data =>
                        data.communitiesReport[0].daysReport.map(row => ({
                            ['total']: row.interactions,
                            ['stages']: row.interactionResults.map(stage => ({
                                name: stage.interactionType.name,
                                count: stage.count,
                            })),
                            ['date']: row.date,
                        }))
                    }
                    currentDate={moment()}
                    label={t('interactions.legend')}
                />
            </Card>
        </div>
    );
};

export default InteractionsPage;

InteractionsPage.propTypes = {};
