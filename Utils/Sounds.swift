import AVFoundation

@dynamicMemberLookup final class Sounds {
    struct SystemSound {
        let id: UInt32

        func play() {
            AudioServicesPlaySystemSound(id)
        }
    }

    private static let `default` = Sounds()

    static subscript(dynamicMember member: String) -> SystemSound {
        SystemSound(id: `default`.sounds[member.capitalized, default: 0])
    }

    private let sounds: [String: UInt32]

    private init() {
        let allSounds = ["Basso", "Blow", "Bottle", "Frog", "Funk", "Glass", "Hero", "Morse", "Ping", "Pop", "Purr", "Sosumi", "Submarine", "Tink"]

        var sounds: [String: UInt32] = [:]

        var soundID: UInt32 = 0

        for sound in allSounds {
            if let url = Bundle.main.url(forResource: sound, withExtension: "aiff") {
                AudioServicesCreateSystemSoundID(url as CFURL, &soundID)
            }

            sounds[sound] = soundID
        }

        self.sounds = sounds
    }

    deinit {
        for (_, id) in sounds {
            AudioServicesDisposeSystemSoundID(id)
        }
    }

    static func playCorrectSound() {
        Sounds.blow.play()
    }

    static func playIncorrectSound() {
        Sounds.basso.play()
    }

    static func playSplitSound() {
        Sounds.tink.play()
    }

    static func playClickSound() {
        Sounds.frog.play()
    }
}
