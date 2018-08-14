import i18next from 'i18next';
import isoLanguages from 'iso-639-1';
import countrilyData from 'countrily-data';
import m49Regions from 'm49-regions';

const recursiveFind = (arr, findKey, findValue, recurseKey) => {
    return arr.reduce((acc, item) => {
        if (acc) {
            return acc;
        }

        if (item[findKey] === findValue) {
            return item;
        }

        return item[recurseKey]
            ? recursiveFind(item[recurseKey], findKey, findValue, recurseKey)
            : undefined;
    }, undefined);
};

export const getNamesOfLoadedTranslations = () =>
    Object.keys(i18next.store.data)
        .map(code => {
            const [language, country] = code.split('-');

            const languageName = isoLanguages.getName(language);
            const countryName =
                country &&
                (country.match(/^\d{3}$/)
                    ? (recursiveFind(m49Regions, 'code', country, 'sub') || {})
                          .name
                    : (
                          countrilyData.find(
                              countrilyCountry =>
                                  countrilyCountry.ISO.alpha2 === country,
                          ) || {}
                      ).demonym);

            return {
                code,
                name: `${languageName}${
                    countryName ? ` - ${countryName}` : ''
                } (${code})`,
            };
        })
        .sort((a, b) => a.name.localeCompare(b.name));
