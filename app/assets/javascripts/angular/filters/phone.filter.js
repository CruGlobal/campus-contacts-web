// Adapted from: http://stackoverflow.com/questions/12700145/how-to-format-a-telephone-number-in-angularjs

angular.module('campusContactsApp').filter('phone', function () {
  return function (inputNumber) {
    if (!inputNumber) {
      return '';
    }

    const value = inputNumber.toString().trim().replace(/\D/g, '');

    let country, city, number;

    switch (value.length) {
      case 10: // +1PPP####### -> C (PPP) ###-####
        country = 1;
        city = value.slice(0, 3);
        number = value.slice(3);
        break;

      case 11: // +CPPP####### -> CCC (PP) ###-####
        country = value[0];
        city = value.slice(1, 4);
        number = value.slice(4);
        break;

      case 12: // +CCCPP####### -> CCC (PP) ###-####
        country = value.slice(0, 3);
        city = value.slice(3, 5);
        number = value.slice(5);
        break;

      default:
        return inputNumber;
    }

    if (country === 1) {
      country = '';
    }

    number = number.slice(0, 3) + '-' + number.slice(3);

    return (country + ' (' + city + ') ' + number).trim();
  };
});
