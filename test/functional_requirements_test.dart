import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ping_my_therapist/core/auth/password_policy.dart';
import 'package:ping_my_therapist/services/appointment_service.dart';
import 'package:ping_my_therapist/services/spotify_service.dart';

void main() {
  group('UC-01 registration password policy', () {
    test('accepts a password meeting every SRS character rule', () {
      expect(validateNewPassword('Strong#9a'), isNull);
    });

    test('rejects missing length, character classes and whitespace', () {
      for (final password in [
        'Short#1',
        'lowercase#1',
        'UPPERCASE#1',
        'NoNumber#',
        'NoSymbol12',
        'Space #Aa1',
        'Tab\t#Aa1',
        'Password#1',
      ]) {
        expect(validateNewPassword(password), isNotNull, reason: password);
      }
    });
  });

  group('UC-07 therapist directory and booking data', () {
    test('normalizes current portal and legacy availability', () {
      expect(
        TherapistInfo.normalizeAvailability([
          {'day': 'Sunday', 'enabled': true, 'start': '10:00', 'end': '14:00'},
          {'day': 'Monday', 'enabled': false, 'start': '09:00'},
          {'dayOfWeek': 2, 'startTime': '12:00', 'endTime': '15:00'},
          {'dayOfWeek': 8},
          {'day': 'Neverday'},
          null,
        ]),
        [
          {'dayOfWeek': 0, 'startTime': '10:00', 'endTime': '14:00'},
          {'dayOfWeek': 2, 'startTime': '12:00', 'endTime': '15:00'},
        ],
      );
    });

    test(
      'reads web-created pending appointments with Firestore timestamps',
      () {
        final scheduled = DateTime.utc(2026, 10, 7, 13);
        final appointment = AppointmentModel.fromMap('booking-1', {
          'patientId': 'patient-1',
          'therapistUid': 'therapist-1',
          'scheduledAt': Timestamp.fromDate(scheduled),
          'duration': 45,
          'status': 'Pending',
          'source': 'therapist',
        });

        expect(appointment.id, 'booking-1');
        expect(appointment.patientId, 'patient-1');
        expect(appointment.scheduledAt.toUtc(), scheduled);
        expect(appointment.duration, 45);
        expect(appointment.status, 'pending');
        expect(appointment.source, 'therapist');
      },
    );

    test('reads ISO date from portal and defaults optional fields', () {
      final appointment = AppointmentModel.fromMap('booking-2', {
        'scheduledAt': '2026-10-07T13:00:00Z',
      });
      expect(appointment.scheduledAt, DateTime.utc(2026, 10, 7, 13));
      expect(appointment.duration, 60);
      expect(appointment.status, 'pending');
      expect(appointment.patientId, isEmpty);
    });

    test('blocks only the same therapist pending slot within five minutes', () {
      final slot = DateTime.utc(2026, 10, 8, 12);
      final appointments = [
        {
          'therapistUid': 'other-therapist',
          'status': 'pending',
          'scheduledAt': Timestamp.fromDate(slot),
        },
        {
          'therapistUid': 'therapist-1',
          'status': 'confirmed',
          'scheduledAt': Timestamp.fromDate(slot),
        },
        {
          'therapistUid': 'therapist-1',
          'status': 'Pending',
          'scheduledAt': slot.add(const Duration(minutes: 5)).toIso8601String(),
        },
      ];
      expect(
        containsPendingAppointment(appointments, 'therapist-1', slot),
        isFalse,
      );

      appointments.add({
        'therapistUid': 'therapist-1',
        'status': 'pending',
        'scheduledAt': Timestamp.fromDate(
          slot.add(const Duration(minutes: 4, seconds: 59)),
        ),
      });
      expect(
        containsPendingAppointment(appointments, 'therapist-1', slot),
        isTrue,
      );
    });

    test(
      'does not treat invalid dates or the five-minute boundary as duplicates',
      () {
        final slot = DateTime.utc(2026, 10, 8, 12);
        expect(
          containsPendingAppointment(
            [
              {
                'therapistUid': 'therapist-1',
                'status': 'pending',
                'scheduledAt': 'not-a-date',
              },
              {
                'therapistUid': 'therapist-1',
                'status': 'pending',
                'scheduledAt':
                    slot.subtract(const Duration(minutes: 5)).toIso8601String(),
              },
            ],
            'therapist-1',
            slot,
          ),
          isFalse,
        );
      },
    );
  });

  group('UC-05 mood music fallback', () {
    setUp(() => dotenv.loadFromString(envString: 'SPOTIFY_CLIENT_ID='));
    tearDown(dotenv.clean);

    test('uses curated matching playlists and a usable default', () {
      final service = SpotifyService();
      expect(service.hasCredentials, isFalse);
      final matched = service.getFallbackForMoods(['unknown', 'Cloudy & Low']);
      expect(matched, isNotEmpty);
      expect(matched.first.spotifyUrl, startsWith('https://open.spotify.com/'));
      expect(service.getFallbackForMoods([]), isNotEmpty);
      expect(service.moodSummary([]), 'your mood');
      expect(service.moodSummary(['Cloudy & Low']), 'Cloudy & Low');
    });
  });
}
