//
//  ChordEnumerator.swift
//  HarmonySolver
//
//  Created by Parker Wightman on 2/14/15.
//  Copyright (c) 2015 Alora Studios. All rights reserved.
//

import Foundation

public enum VoiceType {
    case Bass, Tenor, Alto, Soprano
}

extension VoiceType {

    func noteForChord(chord: FourPartChord) -> Note {
        switch self {
        case .Bass: return chord.bass
        case .Tenor: return chord.tenor
        case .Alto: return chord.alto
        case .Soprano: return chord.soprano
        }
    }

}

public func pinnedVoiceConstraint(voiceType: VoiceType, note: Note)(_ chord: FourPartChord) -> Bool {
    if voiceType.noteForChord(chord) == note {
        return true
    }
    return false
}

public func inversionConstraint(inversion: Int)(_ chord: FourPartChord) -> Bool {
    return NoteType(fromValue: chord.chord.semitones[inversion]).cycledBy(chord.chord.noteType.value) == chord.bass.noteType
}

public struct ChordEnumerator : SequenceType {
    public let chord: Chord
    public let randomize: Bool

    public init(chord: Chord, randomize: Bool = false) {
        self.chord = chord
        self.randomize = randomize
    }

    func notesInRange(range: Range<Int>) -> [Note] {
        let set = Set(chord.semitones.map { (self.chord.noteType.value + $0) % 12 })
        return Array(range).filter { set.contains($0 % 12) }.map { Note(absoluteValue: $0) }
    }

    var bassRange: Range<Int> {
        return Note(.E,3).absoluteValue...Note(.C,5).absoluteValue
    }

    var tenorRange: Range<Int> {
        return Note(.C,4).absoluteValue...Note(.G,5).absoluteValue
    }

    var altoRange: Range<Int> {
        return Note(.G,4).absoluteValue...Note(.C,6).absoluteValue
    }

    var sopranoRange: Range<Int> {
        return Note(.C,5).absoluteValue...Note(.G,6).absoluteValue
    }


    public func generate() -> GeneratorOf<FourPartChord> {
        let bassNotes = notesInRange(bassRange)
        let tenorNotes = notesInRange(tenorRange)
        let altoNotes = notesInRange(altoRange)
        let sopranoNotes = notesInRange(sopranoRange)
        let sequences = [bassNotes, tenorNotes, altoNotes, sopranoNotes].reverse().map { range -> [Note] in
            if self.randomize {
                return range.shuffled()
            } else {
                return range
            }
        }
        var generator = PermutationGenerator(sequences: sequences)
        return GeneratorOf {
            if let notes = generator.next() {
                return FourPartChord(
                    chord:   self.chord,
                    bass:    notes[0],
                    tenor:   notes[1],
                    alto:    notes[2],
                    soprano: notes[3]
                )
            } else {
                return nil
            }
        }
    }
}