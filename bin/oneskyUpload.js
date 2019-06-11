import process from 'process';
import oneSky from '@brainly/onesky-utils';
import translations from '../app/assets/i18n/locales/en-US';

async function uploadTranslations() {
    const options = {
        language: 'en-US',
        apiKey: process.env.ONESKY_API_KEY,
        secret: process.env.ONESKY_SECRET_KEY,
        projectId: '240181',
        fileName: 'en-US.json',
        format: 'HIERARCHICAL_JSON',
        content: JSON.stringify(translations),
        keepStrings: true,
    };

    console.log('Uploading to OneSky...');
    try {
        await oneSky.postFile(options);
        console.log('Successfully Uploaded.');
    } catch (error) {
        console.log('Error uploading to OneSky:');
        console.log(error);
        process.exit(1);
    }
}

uploadTranslations();
