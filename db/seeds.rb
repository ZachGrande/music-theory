# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "Seeding music theory quizzes..."

# ==================== EASY QUIZ: Music Basics ====================
basics_quiz = Quiz.find_or_create_by!(title: "Music Basics") do |quiz|
  quiz.description = "Test your knowledge of fundamental music concepts including notes, rhythms, and basic terminology."
  quiz.category = "Fundamentals"
  quiz.difficulty = :easy
end

basics_questions = [
  {
    content: "How many notes are in a standard musical octave?",
    topic: "notes",
    difficulty: :easy,
    answers: [
      { content: "12", correct: true },
      { content: "8", correct: false },
      { content: "7", correct: false },
      { content: "10", correct: false }
    ]
  },
  {
    content: "What does 'piano' mean in musical dynamics?",
    topic: "rhythm",
    difficulty: :easy,
    answers: [
      { content: "Soft", correct: true },
      { content: "Loud", correct: false },
      { content: "Fast", correct: false },
      { content: "Slow", correct: false }
    ]
  },
  {
    content: "What does 'forte' mean in musical dynamics?",
    topic: "rhythm",
    difficulty: :easy,
    answers: [
      { content: "Loud", correct: true },
      { content: "Soft", correct: false },
      { content: "Moderate", correct: false },
      { content: "Very soft", correct: false }
    ]
  },
  {
    content: "Which note is also called the 'whole note'?",
    topic: "rhythm",
    difficulty: :easy,
    answers: [
      { content: "Semibreve", correct: true },
      { content: "Minim", correct: false },
      { content: "Crotchet", correct: false },
      { content: "Quaver", correct: false }
    ]
  },
  {
    content: "What is the musical term for gradually getting louder?",
    topic: "rhythm",
    difficulty: :easy,
    answers: [
      { content: "Crescendo", correct: true },
      { content: "Decrescendo", correct: false },
      { content: "Fortissimo", correct: false },
      { content: "Pianissimo", correct: false }
    ]
  },
  {
    content: "How many beats does a quarter note get in 4/4 time?",
    topic: "rhythm",
    difficulty: :easy,
    answers: [
      { content: "1 beat", correct: true },
      { content: "2 beats", correct: false },
      { content: "4 beats", correct: false },
      { content: "1/2 beat", correct: false }
    ]
  },
  {
    content: "What is the name of the five horizontal lines music is written on?",
    topic: "notes",
    difficulty: :easy,
    answers: [
      { content: "Staff (or Stave)", correct: true },
      { content: "Ledger", correct: false },
      { content: "Bar", correct: false },
      { content: "Measure", correct: false }
    ]
  },
  {
    content: "What symbol indicates silence in music?",
    topic: "rhythm",
    difficulty: :easy,
    answers: [
      { content: "Rest", correct: true },
      { content: "Fermata", correct: false },
      { content: "Tie", correct: false },
      { content: "Slur", correct: false }
    ]
  }
]

basics_questions.each do |q_data|
  question = basics_quiz.questions.find_or_create_by!(content: q_data[:content]) do |q|
    q.topic = q_data[:topic]
    q.difficulty = q_data[:difficulty]
  end

  q_data[:answers].each do |a_data|
    question.answers.find_or_create_by!(content: a_data[:content]) do |a|
      a.correct = a_data[:correct]
    end
  end
end

# ==================== MEDIUM QUIZ: Intervals ====================
intervals_quiz = Quiz.find_or_create_by!(title: "Intervals") do |quiz|
  quiz.description = "Identify and understand musical intervals - the distance between two notes."
  quiz.category = "Theory"
  quiz.difficulty = :medium
end

intervals_questions = [
  {
    content: "What interval is formed between C and G?",
    topic: "intervals",
    difficulty: :medium,
    answers: [
      { content: "Perfect 5th", correct: true },
      { content: "Perfect 4th", correct: false },
      { content: "Major 3rd", correct: false },
      { content: "Major 6th", correct: false }
    ]
  },
  {
    content: "What interval is formed between C and E?",
    topic: "intervals",
    difficulty: :medium,
    answers: [
      { content: "Major 3rd", correct: true },
      { content: "Minor 3rd", correct: false },
      { content: "Perfect 4th", correct: false },
      { content: "Major 2nd", correct: false }
    ]
  },
  {
    content: "How many half steps are in a minor 3rd?",
    topic: "intervals",
    difficulty: :medium,
    answers: [
      { content: "3", correct: true },
      { content: "4", correct: false },
      { content: "2", correct: false },
      { content: "5", correct: false }
    ]
  },
  {
    content: "What is the interval from C to F called?",
    topic: "intervals",
    difficulty: :medium,
    answers: [
      { content: "Perfect 4th", correct: true },
      { content: "Perfect 5th", correct: false },
      { content: "Major 3rd", correct: false },
      { content: "Augmented 4th", correct: false }
    ]
  },
  {
    content: "How many half steps are in a perfect 5th?",
    topic: "intervals",
    difficulty: :medium,
    answers: [
      { content: "7", correct: true },
      { content: "5", correct: false },
      { content: "6", correct: false },
      { content: "8", correct: false }
    ]
  },
  {
    content: "What is the inversion of a major 3rd?",
    topic: "intervals",
    difficulty: :medium,
    answers: [
      { content: "Minor 6th", correct: true },
      { content: "Major 6th", correct: false },
      { content: "Minor 3rd", correct: false },
      { content: "Perfect 5th", correct: false }
    ]
  },
  {
    content: "What interval is also known as a 'tritone'?",
    topic: "intervals",
    difficulty: :medium,
    answers: [
      { content: "Augmented 4th / Diminished 5th", correct: true },
      { content: "Perfect 4th", correct: false },
      { content: "Perfect 5th", correct: false },
      { content: "Major 3rd", correct: false }
    ]
  },
  {
    content: "How many half steps are in a major 2nd?",
    topic: "intervals",
    difficulty: :medium,
    answers: [
      { content: "2", correct: true },
      { content: "1", correct: false },
      { content: "3", correct: false },
      { content: "4", correct: false }
    ]
  }
]

intervals_questions.each do |q_data|
  question = intervals_quiz.questions.find_or_create_by!(content: q_data[:content]) do |q|
    q.topic = q_data[:topic]
    q.difficulty = q_data[:difficulty]
  end

  q_data[:answers].each do |a_data|
    question.answers.find_or_create_by!(content: a_data[:content]) do |a|
      a.correct = a_data[:correct]
    end
  end
end

# ==================== MEDIUM QUIZ: Chords ====================
chords_quiz = Quiz.find_or_create_by!(title: "Chord Basics") do |quiz|
  quiz.description = "Learn about major, minor, and other chord types and their construction."
  quiz.category = "Theory"
  quiz.difficulty = :medium
end

chords_questions = [
  {
    content: "What notes make up a C major chord?",
    topic: "chords",
    difficulty: :medium,
    answers: [
      { content: "C, E, G", correct: true },
      { content: "C, Eb, G", correct: false },
      { content: "C, E, G#", correct: false },
      { content: "C, F, G", correct: false }
    ]
  },
  {
    content: "What is the difference between a major and minor triad?",
    topic: "chords",
    difficulty: :medium,
    answers: [
      { content: "The 3rd is lowered by a half step in minor", correct: true },
      { content: "The 5th is lowered by a half step in minor", correct: false },
      { content: "The root is different", correct: false },
      { content: "Minor has 4 notes instead of 3", correct: false }
    ]
  },
  {
    content: "What notes make up an A minor chord?",
    topic: "chords",
    difficulty: :medium,
    answers: [
      { content: "A, C, E", correct: true },
      { content: "A, C#, E", correct: false },
      { content: "A, C, Eb", correct: false },
      { content: "A, B, E", correct: false }
    ]
  },
  {
    content: "What type of chord contains a root, major 3rd, and augmented 5th?",
    topic: "chords",
    difficulty: :medium,
    answers: [
      { content: "Augmented", correct: true },
      { content: "Major", correct: false },
      { content: "Diminished", correct: false },
      { content: "Suspended", correct: false }
    ]
  },
  {
    content: "In a 7th chord, what note is added to the triad?",
    topic: "chords",
    difficulty: :medium,
    answers: [
      { content: "The 7th scale degree above the root", correct: true },
      { content: "The 6th scale degree above the root", correct: false },
      { content: "Another root note", correct: false },
      { content: "The 9th scale degree above the root", correct: false }
    ]
  },
  {
    content: "What notes make up a G major chord?",
    topic: "chords",
    difficulty: :medium,
    answers: [
      { content: "G, B, D", correct: true },
      { content: "G, Bb, D", correct: false },
      { content: "G, B, D#", correct: false },
      { content: "G, A, D", correct: false }
    ]
  },
  {
    content: "What is a 'sus4' chord?",
    topic: "chords",
    difficulty: :medium,
    answers: [
      { content: "A chord where the 3rd is replaced by the 4th", correct: true },
      { content: "A chord with 4 notes", correct: false },
      { content: "A chord held for 4 beats", correct: false },
      { content: "A chord in 4th inversion", correct: false }
    ]
  },
  {
    content: "What type of chord has a root, minor 3rd, and diminished 5th?",
    topic: "chords",
    difficulty: :medium,
    answers: [
      { content: "Diminished", correct: true },
      { content: "Minor", correct: false },
      { content: "Augmented", correct: false },
      { content: "Half-diminished", correct: false }
    ]
  }
]

chords_questions.each do |q_data|
  question = chords_quiz.questions.find_or_create_by!(content: q_data[:content]) do |q|
    q.topic = q_data[:topic]
    q.difficulty = q_data[:difficulty]
  end

  q_data[:answers].each do |a_data|
    question.answers.find_or_create_by!(content: a_data[:content]) do |a|
      a.correct = a_data[:correct]
    end
  end
end

# ==================== HARD QUIZ: Scales & Keys ====================
scales_quiz = Quiz.find_or_create_by!(title: "Scales & Key Signatures") do |quiz|
  quiz.description = "Advanced questions about major and minor scales, modes, and key signatures."
  quiz.category = "Theory"
  quiz.difficulty = :hard
end

scales_questions = [
  {
    content: "How many sharps are in the key of F# major?",
    topic: "key_signatures",
    difficulty: :hard,
    answers: [
      { content: "6", correct: true },
      { content: "5", correct: false },
      { content: "7", correct: false },
      { content: "4", correct: false }
    ]
  },
  {
    content: "What is the relative minor of E major?",
    topic: "key_signatures",
    difficulty: :hard,
    answers: [
      { content: "C# minor", correct: true },
      { content: "E minor", correct: false },
      { content: "A minor", correct: false },
      { content: "B minor", correct: false }
    ]
  },
  {
    content: "What mode starts on the 4th degree of a major scale?",
    topic: "scales",
    difficulty: :hard,
    answers: [
      { content: "Lydian", correct: true },
      { content: "Mixolydian", correct: false },
      { content: "Dorian", correct: false },
      { content: "Phrygian", correct: false }
    ]
  },
  {
    content: "What is the pattern of whole and half steps in a natural minor scale?",
    topic: "scales",
    difficulty: :hard,
    answers: [
      { content: "W-H-W-W-H-W-W", correct: true },
      { content: "W-W-H-W-W-W-H", correct: false },
      { content: "W-H-W-W-W-H-W", correct: false },
      { content: "H-W-W-W-H-W-W", correct: false }
    ]
  },
  {
    content: "How many flats are in the key of Db major?",
    topic: "key_signatures",
    difficulty: :hard,
    answers: [
      { content: "5", correct: true },
      { content: "4", correct: false },
      { content: "6", correct: false },
      { content: "3", correct: false }
    ]
  },
  {
    content: "Which mode has a raised 4th compared to the major scale?",
    topic: "scales",
    difficulty: :hard,
    answers: [
      { content: "Lydian", correct: true },
      { content: "Mixolydian", correct: false },
      { content: "Dorian", correct: false },
      { content: "Locrian", correct: false }
    ]
  },
  {
    content: "What is the parallel minor of G major?",
    topic: "key_signatures",
    difficulty: :hard,
    answers: [
      { content: "G minor", correct: true },
      { content: "E minor", correct: false },
      { content: "D minor", correct: false },
      { content: "B minor", correct: false }
    ]
  },
  {
    content: "In harmonic minor, which scale degree is raised?",
    topic: "scales",
    difficulty: :hard,
    answers: [
      { content: "7th", correct: true },
      { content: "6th", correct: false },
      { content: "3rd", correct: false },
      { content: "2nd", correct: false }
    ]
  },
  {
    content: "What mode is also known as the 'major scale'?",
    topic: "scales",
    difficulty: :hard,
    answers: [
      { content: "Ionian", correct: true },
      { content: "Aeolian", correct: false },
      { content: "Lydian", correct: false },
      { content: "Mixolydian", correct: false }
    ]
  },
  {
    content: "What key has 4 sharps?",
    topic: "key_signatures",
    difficulty: :hard,
    answers: [
      { content: "E major", correct: true },
      { content: "D major", correct: false },
      { content: "A major", correct: false },
      { content: "B major", correct: false }
    ]
  }
]

scales_questions.each do |q_data|
  question = scales_quiz.questions.find_or_create_by!(content: q_data[:content]) do |q|
    q.topic = q_data[:topic]
    q.difficulty = q_data[:difficulty]
  end

  q_data[:answers].each do |a_data|
    question.answers.find_or_create_by!(content: a_data[:content]) do |a|
      a.correct = a_data[:correct]
    end
  end
end

puts "Seeding complete!"
puts "Created #{Quiz.count} quizzes with #{Question.count} questions and #{Answer.count} answers."
