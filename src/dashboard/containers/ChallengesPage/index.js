import React, { useContext } from 'react';
import { useTranslation } from 'react-i18next';
import moment from 'moment';

import Card from '../../components/Card';
import AppContext from '../../appContext';
import Table from '../../components/Table';
import ImpactInfo from '../../components/ImpactInfo';

import { GET_IMPACT_CHALLENGES, GET_CHALLENGES } from './queries';

const ChallengesPage = () => {
    const { t } = useTranslation('insights');
    const { orgId } = useContext(AppContext);

    const mapRows = data => {
        const percentage = (a, b) => {
            const value = b === 0 ? 0 : Math.floor((a / b) * 100);
            return `${a} (${value}%)`;
        };

        const duration = (start, end) => {
            const startDate = moment(start).startOf('day');
            const endDate = moment(end).startOf('day');
            const days = moment.duration(endDate.diff(startDate)).asDays();
            return days === 1 ? '1 Day' : `${days} Days`;
        };

        const range = (start, end) => {
            const format = 'MM/DD/YYYY';
            const startDate = moment(start).format(format);
            const endDate = moment(end).format(format);
            return `${startDate} - ${endDate}`;
        };

        return data.globalCommunityChallenges.nodes.map(
            ({
                id,
                title,
                acceptedCount,
                completedCount,
                createdAt,
                endDate,
            }) => [
                id,
                title,
                acceptedCount,
                percentage(completedCount, acceptedCount),
                duration(createdAt, endDate),
                range(createdAt, endDate),
            ],
        );
    };

    const mapPage = data => {
        return data.globalCommunityChallenges.pageInfo;
    };

    return (
        <div>
            <ImpactInfo
                query={GET_IMPACT_CHALLENGES}
                text={report =>
                    t('challenges.total', {
                        count:
                            report.communityReport.impactReport.challengesCount,
                    })
                }
                variables={{ organizationId: orgId }}
            />
            <Card
                title={t('challenges.title')}
                subtitle={t('challenges.subTitle')}
                noPadding={true}
            >
                <Table
                    query={GET_CHALLENGES}
                    variables={{ id: orgId }}
                    headers={[
                        '',
                        '',
                        t('challenges.join'),
                        t('challenges.completed'),
                        t('challenges.length'),
                        t('challenges.dates'),
                    ]}
                    mapRows={mapRows}
                    mapPage={mapPage}
                />
            </Card>
        </div>
    );
};

export default ChallengesPage;

ChallengesPage.propTypes = {};